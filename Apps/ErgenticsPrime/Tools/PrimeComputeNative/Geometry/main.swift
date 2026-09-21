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
func checksum(_ v:[Float]) -> UInt64 { v.reduce(UInt64(0xcbf29ce484222325)) { ($0 ^ UInt64($1.bitPattern)) &* 0x100000001b3 } }

struct Node: Codable { let x:Float; let y:Float; let weight:Float }
struct Request: Codable {
    let points:[[Float]]; let nodes:[Node]; let sigma:Float; let execution:String
    func input() throws -> EPRPrimeComputeInput {
        try require((1...200).contains(points.count) && (1...64).contains(nodes.count),"point/node count out of range")
        try require(points.allSatisfy { $0.count==2 && $0.allSatisfy(\.isFinite) },"finite 2D points required")
        try require(nodes.allSatisfy { $0.x.isFinite && $0.y.isFinite && $0.weight.isFinite },"finite nodes required")
        try require(["host","guest"].contains(execution) && sigma.isFinite && sigma>0,"invalid execution or sigma")
        let ps=points.map { SIMD2(Double($0[0]),Double($0[1])) }
        let ns=nodes.map { MetalFieldEvaluator.GPUNode(pos:SIMD2($0.x,$0.y),weight:$0.weight) }
        try require(MetalFieldEvaluator.inputsValid(points:ps,nodes:ns,sigma:Double(sigma)),"sigma cannot support finite F32 kernel arithmetic")
        var v=EPRPrimeComputeInput();v.pointCount=UInt32(points.count);v.nodeCount=UInt32(nodes.count);v.sigma=sigma
        withUnsafeMutableBytes(of:&v.pointsXY) { raw in
            let b=raw.bindMemory(to:Float.self)
            for (i,p) in points.enumerated() {b[i*2]=p[0];b[i*2+1]=p[1]}
        }
        withUnsafeMutableBytes(of:&v.nodesXYWeight) { raw in
            let b=raw.bindMemory(to:Float.self)
            for (i,n) in nodes.enumerated() {b[i*3]=n.x;b[i*3+1]=n.y;b[i*3+2]=n.weight}
        }
        return v
    }
}
func canonical(_ path:String) throws -> String {
    try require(path.hasPrefix("/") && path.utf8.count<=4096 && !path.utf8.contains(0),"canonical absolute path required")
    guard let p=realpath(path,nil) else {throw Failure(message:"path cannot be resolved")}
    defer {free(p)}
    try require(String(cString:p)==path,"path aliases are not accepted")
    return path
}
func readRequest(_ path:String) throws -> Data {
    _=try canonical(path)
    let fd=open(path,O_RDONLY|O_CLOEXEC|O_NOFOLLOW_ANY)
    try require(fd>=0,"request open failed")
    defer {close(fd)}
    var st=stat();try require(fstat(fd,&st)==0 && st.st_mode&S_IFMT==S_IFREG && st.st_size>0 && st.st_size<=131072,"request size/type invalid")
    var data=Data(count:Int(st.st_size))
    try data.withUnsafeMutableBytes { raw in
        var offset=0
        while offset<raw.count {
            let n=pread(fd,raw.baseAddress!.advanced(by:offset),raw.count-offset,off_t(offset))
            if n<0 && errno==EINTR {continue}
            try require(n>0,"request read failed");offset+=n
        }
    }
    var after=stat(),named=stat()
    try require(fstat(fd,&after)==0 && lstat(path,&named)==0 && st.st_dev==named.st_dev && st.st_ino==named.st_ino &&
        st.st_size==after.st_size && st.st_mtimespec.tv_sec==after.st_mtimespec.tv_sec && st.st_mtimespec.tv_nsec==after.st_mtimespec.tv_nsec &&
        st.st_ctimespec.tv_sec==after.st_ctimespec.tv_sec && st.st_ctimespec.tv_nsec==after.st_ctimespec.tv_nsec,"request changed")
    return data
}
func run(_ path:String,_ out:URL) throws {
    let admission=prime_inference_inspect_admission()
    try save(readable(admission),"admission.json",out)
    try require(admission.status==1,"app helper admission rejected: reason \(admission.reason), security \(admission.security_status)")
    let data=try readRequest(path)
    guard let object=try JSONSerialization.jsonObject(with:data) as? [String:Any],
          Set(object.keys)==["points","nodes","sigma","execution"],
          let nodes=object["nodes"] as? [[String:Any]],nodes.allSatisfy({Set($0.keys)==["x","y","weight"]}) else {
        throw Failure(message:"unsupported request fields")
    }
    let request=try JSONDecoder().decode(Request.self,from:data),template=try request.input()
    try raw(data,"request.json",out);try raw(bytes(template),"input.bin",out)
    let initialize=DispatchTime.now().uptimeNanoseconds
    guard let evaluator=MetalFieldEvaluator() else {throw Failure(message:"Metal initialization failed")}
    let initializationNs=DispatchTime.now().uptimeNanoseconds-initialize
    let c=Context(evaluator,template)
    var guest:Any=NSNull(),guestChecksum:Any=NSNull()
    let began=DispatchTime.now().uptimeNanoseconds
    if request.execution=="host" { _=try c.evaluate(template) }
    else {
        var supplied=template,r=EPRPrimeComputeResult()
        let status=epr_prime_compute_run(&supplied,callback,Unmanaged.passUnretained(c).toOpaque(),&r)
        try raw(bytes(r),"guest.bin",out);try save(readable(r),"guest.json",out)
        try require(status==0 && r.cleanupComplete==1 && r.callbackCount==1 && r.runCount==2 && r.checksumMatched==1 &&
                    r.guestReadCount==template.pointCount*3,"guest request, readback or cleanup failed")
        try require(c.error==nil && bytes(r.observedInput)==bytes(template),"guest/callback input mismatch")
        let returned=array(r.observedReply.values,request.points.count*3)
        try require(returned.map(\.bitPattern)==c.produced.map(\.bitPattern) && r.guestChecksum==checksum(c.produced),"guest did not consume actual GPU vector")
        guest=readable(r);guestChecksum=r.guestChecksum
    }
    let wall=DispatchTime.now().uptimeNanoseconds-began
    let referenceBegan=DispatchTime.now().uptimeNanoseconds
    try c.validateCPU(template)
    let cpuNs=DispatchTime.now().uptimeNanoseconds-referenceBegan
    try require(c.calls==1 && evaluator.submittedDispatchCount==1,"exactly one Metal dispatch required")
    try require(try readRequest(path)==data,"request changed after compute")
    try require(prime_inference_inspect_admission().status==1,"app helper admission changed")
    let n=request.points.count,values=c.produced.withUnsafeBytes {Data($0)}
    try raw(values,"values.f32le",out)
    let result:[String:Any]=["schema":"prime_app_geometry_result_v1","status":"completed","execution":request.execution,
        "device":evaluator.deviceName,"processID":getpid(),"requestSHA256":sha(data),"points":request.points,
        "nodes":request.nodes.map {["x":$0.x,"y":$0.y,"weight":$0.weight]},"sigma":request.sigma,
        "potential":Array(c.produced.prefix(n)),"gradientXY":Array(c.produced.dropFirst(n)),"valueCount":3*n,
        "outputSHA256":sha(values),"guestChecksum":guestChecksum,"guest":guest,
        "admission":readable(admission),"hostProcessContainment":"signed_App_Sandbox_inherited_from_live_application",
        "validation":["CPUComparisonPassed":true,"oneActualMetalDispatch":true,"guestReplyVerified":request.execution=="guest"],
        "timing":["initializationNanoseconds":initializationNs,"computeWallNanoseconds":wall,"CPUReferenceNanoseconds":cpuNs,"dispatch":c.observation],
        "timingScope":"GPU timestamps describe the actual command buffer. computeWall includes route call and guest receipt persistence on the guest route; CPU comparison is measured separately. It does not isolate vCPU hardware cost.",
        "learnedModelInvoked":false,"trainingPerformed":false,"CPUFallback":false,"virtualGPUDeviceImplemented":false]
    try save(result,"result.json",out)
    print("Completed one user-input \(request.execution) Metal geometry request.")
}
@main enum Main {
    static func main() {
        umask(0o077);alarm(120)
        let parent=getppid();guard parent>1 else {Darwin._exit(75)}
        let watchdog=DispatchSource.makeTimerSource(queue:DispatchQueue(label:"prime.geometry.parent"))
        watchdog.schedule(deadline:.now(),repeating:.milliseconds(200))
        watchdog.setEventHandler {if getppid() != parent {Darwin._exit(75)}}
        watchdog.resume();defer {watchdog.cancel()}
        var output:URL?
        do {
            let a=CommandLine.arguments
            try require(a.count==5 && a[1]=="--request" && a[3]=="--output-directory","usage: PrimeGeometryService --request ABS_JSON --output-directory ABS_FRESH_DIR")
            let url=URL(fileURLWithPath:a[4]);let parent=try canonical(url.deletingLastPathComponent().path)
            try require(a[4].hasPrefix("/") && parent+"/"+url.lastPathComponent==a[4] && ![".","..",""] .contains(url.lastPathComponent),"canonical fresh output required")
            try require(Darwin.mkdir(a[4],0o700)==0,"fresh output directory required");output=url
            try run(a[2],url);alarm(0)
        } catch {
            if let output {try? save(["status":"failed","error":String(describing:error)],"error.json",output)}
            fputs("Prime geometry failed: \(error)\n",stderr);exit(70)
        }
    }
}
