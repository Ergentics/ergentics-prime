import Foundation
import Darwin
import CryptoKit
import Metal

struct Failure: Error { let message: String }
func require(_ ok: Bool, _ message: String) throws { if !ok { throw Failure(message:message) } }
func bytes<T>(_ x: T) -> Data { var v=x; return withUnsafeBytes(of:&v) { Data($0) } }
func sha(_ d: Data) -> String { SHA256.hash(data:d).map { String(format:"%02x",$0) }.joined() }
func readable(_ value: Any) -> Any {
    if let v=value as? Float { return v.isFinite ? v as Any : String(describing:v) }
    if let v=value as? Double { return v.isFinite ? v as Any : String(describing:v) }
    if let v=value as? NSNumber { return v }
    if let v=value as? String { return v }
    let m=Mirror(reflecting:value)
    if m.displayStyle == .tuple || m.displayStyle == .collection { return m.children.map { readable($0.value) } }
    return Dictionary(uniqueKeysWithValues:m.children.enumerated().map { (i,v) in (v.label ?? String(i),readable(v.value)) })
}
func save(_ value: Any, _ name: String, _ out: URL) throws {
    let d=try JSONSerialization.data(withJSONObject:value,options:[.sortedKeys,.prettyPrinted,.withoutEscapingSlashes])
    try (d+Data([10])).write(to:out.appendingPathComponent(name),options:.withoutOverwriting)
}
func raw(_ data: Data,_ name:String,_ out:URL) throws { try data.write(to:out.appendingPathComponent(name),options:.withoutOverwriting) }
func array<T>(_ tuple: T,_ count:Int) -> [Float] { var t=tuple; return withUnsafeBytes(of:&t) { Array($0.bindMemory(to:Float.self).prefix(count)) } }
func input(_ count:Int) -> EPRPrimeComputeInput {
    var v=EPRPrimeComputeInput();v.pointCount=UInt32(count);v.nodeCount=12;v.sigma=0.42
    withUnsafeMutableBytes(of:&v.pointsXY) { raw in
        let b=raw.bindMemory(to:Float.self)
        for i in 0..<count { b[i*2]=Float(-1.2+2.4*Double(i%20)/19);b[i*2+1]=Float(-1.2+2.4*Double(i/20)/9) }
    }
    withUnsafeMutableBytes(of:&v.nodesXYWeight) { raw in
        let b=raw.bindMemory(to:Float.self)
        for i in 0..<12 { b[i*3]=Float(-0.75+0.5*Double(i%4));b[i*3+1]=Float(-0.6+0.6*Double(i/4));b[i*3+2]=Float(0.2+0.1*Double(i)) }
    }
    return v
}
final class Context {
    let evaluator: MetalFieldEvaluator
    let expected: EPRPrimeComputeInput
    var produced=[Float](), observation=[String:Any](), calls=0, error: String?
    init(_ evaluator: MetalFieldEvaluator,_ expected:EPRPrimeComputeInput) {self.evaluator=evaluator;self.expected=expected}
    func evaluate(_ supplied:EPRPrimeComputeInput) throws -> [Float] {
        calls += 1
        try require(bytes(supplied)==bytes(expected),"callback input differs from declared guest request")
        let n=Int(supplied.pointCount),k=Int(supplied.nodeCount)
        let xy=array(supplied.pointsXY,n*2),ns=array(supplied.nodesXYWeight,k*3)
        let points=(0..<n).map { SIMD2(Double(xy[$0*2]),Double(xy[$0*2+1])) }
        let nodes=(0..<k).map { MetalFieldEvaluator.GPUNode(pos:SIMD2(ns[$0*3],ns[$0*3+1]),weight:ns[$0*3+2]) }
        let began=DispatchTime.now().uptimeNanoseconds
        guard let result=evaluator.evaluate(points:points,nodes:nodes,sigma:Double(supplied.sigma)) else { throw Failure(message:"Metal compute failed") }
        let elapsed=DispatchTime.now().uptimeNanoseconds-began
        produced=result.v.map(Float.init)+result.grad.flatMap { [Float($0.x),Float($0.y)] }
        var gpu: Any=NSNull()
        if let s=evaluator.lastGPUStartTime, let e=evaluator.lastGPUEndTime, e>=s { gpu=(e-s)*1e9 }
        observation=["callbackWallNanoseconds":elapsed,"gpuNanoseconds":gpu,
            "gpuStartHostSeconds":evaluator.lastGPUStartTime as Any? ?? NSNull(),"gpuEndHostSeconds":evaluator.lastGPUEndTime as Any? ?? NSNull(),
            "commandBufferStatus":evaluator.lastCommandBufferStatus as Any? ?? NSNull(),
            "valueCount":produced.count,"outputSHA256":sha(produced.withUnsafeBytes { Data($0) }),"CPUFallback":false]
        return produced
    }
    func validateCPU(_ supplied:EPRPrimeComputeInput) throws {
        let n=Int(supplied.pointCount),k=Int(supplied.nodeCount)
        let xy=array(supplied.pointsXY,n*2),ns=array(supplied.nodesXYWeight,k*3)
        let points=(0..<n).map { SIMD2(Double(xy[$0*2]),Double(xy[$0*2+1])) }
        var layout=[String:SIMD2<Double>](),weights=[String:Double]()
        for i in 0..<k { layout[String(i)]=SIMD2(Double(ns[i*3]),Double(ns[i*3+1]));weights[String(i)]=Double(ns[i*3+2]) }
        var maxV=0.0,maxG=0.0
        for i in 0..<n {
            let v=FieldPotential.V(at:points[i],layout:layout,weights:weights,sigma:Double(supplied.sigma))
            let g=FieldPotential.gradV(at:points[i],layout:layout,weights:weights,sigma:Double(supplied.sigma))
            let dv=abs(v-Double(produced[i]));maxV=max(maxV,dv)
            try require(dv <= max(1e-5,1e-4*max(abs(v),abs(Double(produced[i])))),"potential CPU parity failed")
            for (a,b) in [(g.x,Double(produced[n+i*2])),(g.y,Double(produced[n+i*2+1]))] {
                let d=abs(a-b);maxG=max(maxG,d)
                try require(d <= max(1e-4,1e-3*max(abs(a),abs(b))),"gradient CPU parity failed")
            }
        }
        observation["maximumPotentialError"]=maxV
        observation["maximumGradientError"]=maxG
    }
}
func callback(_ p:UnsafeMutableRawPointer?,_ source:UnsafePointer<EPRPrimeComputeInput>?,_ reply:UnsafeMutablePointer<EPRPrimeComputeReply>?) -> Int32 {
    guard let p,let source,let reply else {return -1}
    let c=Unmanaged<Context>.fromOpaque(p).takeUnretainedValue()
    do {
        let values=try c.evaluate(source.pointee)
        reply.pointee=EPRPrimeComputeReply();reply.pointee.valueCount=UInt32(values.count)
        withUnsafeMutableBytes(of:&reply.pointee.values) { raw in
            let b=raw.bindMemory(to:Float.self);for (i,v) in values.enumerated() {b[i]=v}
        }
        return 0
    } catch {c.error=String(describing:error);return -2}
}
func invalidReply(_ p:UnsafeMutableRawPointer?,_ source:UnsafePointer<EPRPrimeComputeInput>?,_ reply:UnsafeMutablePointer<EPRPrimeComputeReply>?) -> Int32 {
    guard let source,let reply else {return -1}
    reply.pointee=EPRPrimeComputeReply();reply.pointee.valueCount=source.pointee.pointCount*3
    withUnsafeMutableBytes(of:&reply.pointee.values) { $0.bindMemory(to:Float.self)[0] = .nan }
    return 0
}
func checksum(_ v:[Float]) -> UInt64 { v.reduce(UInt64(0xcbf29ce484222325)) { ($0 ^ UInt64($1.bitPattern)) &* 0x100000001b3 } }
func run(_ out:URL) throws {
    let admission=prime_inference_inspect_admission();try save(readable(admission),"admission.json",out)
    try require(admission.status==1,"signed helper admission failed")
    let begin=DispatchTime.now().uptimeNanoseconds
    guard let evaluator=MetalFieldEvaluator() else {throw Failure(message:"Metal initialization failed")}
    let initializationNs=DispatchTime.now().uptimeNanoseconds-begin
    var warmup=[[String:Any]]()
    for _ in 0..<2 {let c=Context(evaluator,input(200));_=try c.evaluate(c.expected);warmup.append(c.observation)}
    try save(warmup,"warmup.json",out)
    var results=[[String:Any]]();var sumValues=0
    for count in [1,32,200] {
        let template=input(count);try raw(bytes(template),"input-\(count).bin",out);try save(readable(template),"input-\(count).json",out)
        for repetition in 0..<8 {
            var hostData=Data(),guestData=Data()
            for route in repetition%2 == 0 ? ["host","guest"] : ["guest","host"] {
                let c=Context(evaluator,template);var observations=[String:Any]()
                let started=DispatchTime.now().uptimeNanoseconds
                var wall: UInt64=0
                if route=="host" { _=try c.evaluate(template);wall=DispatchTime.now().uptimeNanoseconds-started }
                else {
                    var supplied=template,r=EPRPrimeComputeResult()
                    let status=epr_prime_compute_run(&supplied,callback,Unmanaged.passUnretained(c).toOpaque(),&r)
                    wall=DispatchTime.now().uptimeNanoseconds-started
                    try raw(bytes(r),"guest-\(count)-\(repetition).bin",out)
                    try save(readable(r),"guest-\(count)-\(repetition).json",out)
                    try require(status==0 && r.cleanupComplete==1 && r.callbackCount==1 && r.runCount==2 && r.checksumMatched==1 && r.guestReadCount==UInt32(count*3),"guest request, readback or cleanup failed")
                    try require(c.error==nil && bytes(r.observedInput)==bytes(template),"guest/callback input mismatch")
                    let returned=array(r.observedReply.values,count*3)
                    try require(returned.map(\.bitPattern)==c.produced.map(\.bitPattern) && r.guestChecksum==checksum(c.produced),"guest reply does not match actual GPU vector")
                    observations=["guestChecksum":r.guestChecksum,"guestReadCount":r.guestReadCount,"guestElapsedNanoseconds":r.elapsedNanoseconds,"VMCreated":true,"cleanupComplete":true]
                    sumValues += Int(r.guestReadCount)
                }
                try c.validateCPU(template)
                try require(c.calls==1,"exactly one dispatch required")
                let data=c.produced.withUnsafeBytes {Data($0)};try raw(data,"\(route)-\(count)-\(repetition).f32le",out)
                if route=="host" {hostData=data} else {guestData=data}
                observations.merge(c.observation) {_,new in new};observations.merge(["route":route,"pointCount":count,"nodeCount":12,"repetition":repetition,"totalWallNanoseconds":wall]) {_,new in new}
                results.append(observations)
            }
            try require(hostData==guestData,"host and guest GPU outputs differ")
        }
    }
    var invalids=[[String:Any]]()
    for index in 0..<3 {
        var bad=input(1);if index==0 {bad.pointCount=201};if index==1 {bad.nodeCount=0};if index==2 {bad.sigma=0}
        let c=Context(evaluator,bad);var r=EPRPrimeComputeResult()
        let status=epr_prime_compute_run(&bad,callback,Unmanaged.passUnretained(c).toOpaque(),&r)
        try require(status==1 && c.calls==0 && r.callbackCount==0 && r.runCount==0,"invalid input reached compute")
        invalids.append(["case":index,"result":readable(r)])
    }
    var supplied=input(1),badReply=EPRPrimeComputeResult()
    let badStatus=epr_prime_compute_run(&supplied,invalidReply,nil,&badReply)
    try raw(bytes(badReply),"invalid-reply.bin",out)
    try require(badStatus==7 && badReply.cleanupComplete==1 && badReply.callbackCount==1 && badReply.completionHVCCount==0,"nonfinite reply not rejected")
    invalids.append(["case":"nonfinite_fixture_reply_no_GPU","result":readable(badReply)])
    try save(invalids,"invalid-checks.json",out)
    try require(evaluator.submittedDispatchCount==50,"unexpected GPU dispatch count")
    let result:[String:Any]=["schema":"prime_guest_gpu_offload_measurement_v1","status":"PASS","measurements":results,
        "device":evaluator.deviceName,"initializationNanoseconds":initializationNs,"warmupDispatches":2,"measuredDispatches":48,
        "measuredGuestVMs":24,"negativeReplyVMs":1,"guestReturnedFloatValues":sumValues,"measuredGuestEntries":48,
        "hostGuestIdenticalPairs":24,"learnedModelInvoked":false,"trainingPerformed":false,"virtualGPUDeviceImplemented":false,
        "operation":"2D_geometry_potential_and_gradient","execution":"actual_ARM_guest_HVC_host_Metal_compute_float_reply_guest_checksum",
        "timingScope":"GPU timestamps exclude host work. totalWall measures the host evaluate call or guest bridge call, excluding persistence and CPU reference scoring; guestElapsed includes VM setup, callback, guest checksum, watchdog join and teardown. Neither difference isolates vCPU hardware cost.",
        "limitation":"Fixed small diagnostic, 8 paired samples per size. Not a throughput benchmark or full graphics device."]
    try save(result,"result.json",out)
    print("Completed 24 guest GPU vector round trips, 24 host comparisons, and 4 negative checks.")
}
@main enum Main {
    static func main() {
        umask(0o077);alarm(120)
        do {
            let a=CommandLine.arguments;try require(a.count==3 && a[1]=="--output-directory","usage: PrimeGuestGPU --output-directory ABS_FRESH_DIR")
            let url=URL(fileURLWithPath:a[2]);try require(a[2].hasPrefix("/") && url.standardizedFileURL.resolvingSymlinksInPath().path==a[2],"canonical output required")
            try require(Darwin.mkdir(url.path,0o700)==0,"fresh output directory required")
            try run(url);alarm(0)
        } catch {fputs("Prime guest GPU failed: \(error)\n",stderr);exit(70)}
    }
}
