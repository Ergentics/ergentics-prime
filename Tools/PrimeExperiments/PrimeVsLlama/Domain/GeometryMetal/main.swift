import Foundation
import Metal
import CryptoKit
import Darwin
import simd

private struct Failure: Error, CustomStringConvertible { let description: String; init(_ s: String) { description = s } }
private func require(_ b: Bool, _ message: String) throws { if !b { throw Failure(message) } }
private func encoded(_ object: Any) throws -> Data { try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]) }
private func binding(_ data: Data) -> [String: Any] { ["byteCount":data.count, "sha256":SHA256.hash(data:data).map { String(format:"%02x",$0) }.joined()] }
private func floats(_ values: [Double]) -> Data {
    var data = Data()
    for x in values { var bits = Float(x).bitPattern.littleEndian; withUnsafeBytes(of:&bits) { data.append(contentsOf:$0) } }
    return data
}
private func doubles(_ values: [Double]) -> Data {
    var data = Data()
    for x in values { var bits = x.bitPattern.littleEndian; withUnsafeBytes(of:&bits) { data.append(contentsOf:$0) } }
    return data
}
private struct Comparison {
    let absoluteTolerance: Double, relativeTolerance: Double
    var count = 0, failures = 0
    var maxAbsoluteError = 0.0, maxRelativeError = 0.0, maxToleranceRatio = 0.0
    mutating func add(_ actual: Double, _ expected: Double) {
        count += 1
        guard actual.isFinite && expected.isFinite else { failures += 1; return }
        let delta = abs(actual - expected), scale = max(abs(actual),abs(expected),1e-15)
        let tolerance = max(absoluteTolerance,relativeTolerance * scale)
        maxAbsoluteError = max(maxAbsoluteError,delta)
        maxRelativeError = max(maxRelativeError,delta / scale)
        maxToleranceRatio = max(maxToleranceRatio,delta / tolerance)
        if delta > tolerance { failures += 1 }
    }
    var json: [String: Any] { ["count":count,"failures":failures,"absoluteTolerance":absoluteTolerance,"relativeTolerance":relativeTolerance,"maxAbsoluteError":maxAbsoluteError,"maxRelativeError":maxRelativeError,"maxToleranceRatio":maxToleranceRatio] }
}

private func run(_ output: URL) throws {
    let started = DispatchTime.now().uptimeNanoseconds
    // Fixed, public, deterministic input geometry; no model or expected answer enters the GPU.
    let sigma = 0.42
    let points: [SIMD2<Double>] = (0..<200).map { i in
        SIMD2(-1.2 + 2.4 * Double(i % 20) / 19.0, -1.2 + 2.4 * Double(i / 20) / 9.0)
    }
    var layout = [String: SIMD2<Double>](), weights = [String: Double]()
    for i in 0..<12 {
        let key = String(format:"node-%02d",i)
        layout[key] = SIMD2(-0.75 + 0.5 * Double(i % 4), -0.6 + 0.6 * Double(i / 4))
        weights[key] = 0.2 + 0.1 * Double(i)
    }
    let nodes = MetalFieldEvaluator.makeNodes(layout:layout,weights:weights)
    let inputs: [String:Any] = ["sigma":sigma,"pointCount":points.count,"nodeCount":nodes.count,
        "pointsDouble":points.map { [$0.x,$0.y] }, "pointsEffectiveFloat32":points.map { [Double(Float($0.x)),Double(Float($0.y))] },
        "nodes":layout.keys.sorted().enumerated().map { i,key -> [String:Any] in
            let p = layout[key]!, n = nodes[i]
            return ["id":key,"positionDouble":[p.x,p.y],"weightDouble":weights[key]!,"effectiveFloat32":[Double(n.pos.x),Double(n.pos.y),Double(n.weight),Double(n.pad)]]
        }, "generator":"fixed20x10 sample grid, fixed4x3 nodes; source defines all numeric inputs"]
    let inputData = try encoded(inputs); try inputData.write(to:output.appendingPathComponent("inputs.json"),options:.withoutOverwriting)
    guard let evaluator = MetalFieldEvaluator() else { throw Failure("Metal device, shader library or compute pipeline initialization failed; no CPU fallback") }
    try require(MetalFieldEvaluator.inputsValid(points:points,nodes:nodes,sigma:sigma),"valid payload rejected")
    var checks = [[String:Any]]()
    func rejected(_ name: String, _ p: [SIMD2<Double>], _ n: [MetalFieldEvaluator.GPUNode], _ s: Double) throws {
        let before = evaluator.submittedDispatchCount
        let rejected = !MetalFieldEvaluator.inputsValid(points:p,nodes:n,sigma:s) && evaluator.evaluate(points:p,nodes:n,sigma:s) == nil
        try require(rejected && evaluator.submittedDispatchCount == before,"invalid input submitted or accepted: " + name)
        checks.append(["name":name,"rejected":true,"submittedDispatches":0])
    }
    try rejected("empty_points",[],nodes,sigma)
    try rejected("point_count4097",Array(repeating:SIMD2<Double>(0,0),count:4097),nodes,sigma)
    try rejected("empty_nodes",points,[],sigma)
    try rejected("node_count65",points,Array(repeating:nodes[0],count:65),sigma)
    try rejected("nonfinite_point",[SIMD2<Double>(.nan,0)],nodes,sigma)
    try rejected("point_float32_overflow",[SIMD2<Double>(Double.greatestFiniteMagnitude,0)],nodes,sigma)
    var badNodes = nodes; badNodes[0].weight = .infinity
    try rejected("nonfinite_weight",points,badNodes,sigma)
    badNodes = nodes; badNodes[0].pos.x = .nan
    try rejected("nonfinite_node_position",points,badNodes,sigma)
    try rejected("sigma_zero",points,nodes,0)
    try rejected("sigma_negative",points,nodes,-1)
    try rejected("sigma_nan",points,nodes,.nan)
    try rejected("sigma_float32_overflow",points,nodes,Double.greatestFiniteMagnitude)
    try rejected("sigma_squared_underflow",points,nodes,Double(Float.leastNonzeroMagnitude))
    try rejected("sigma_squared_overflow",points,nodes,Double(Float.greatestFiniteMagnitude))
    try require(evaluator.submittedDispatchCount == 0,"invalid checks dispatched GPU work")
    guard let gpu = evaluator.evaluate(points:points,nodes:nodes,sigma:sigma) else { throw Failure("GPU dispatch/readback failed: status \(String(describing:evaluator.lastCommandBufferStatus)), error \(String(describing:evaluator.lastCommandBufferError))") }
    try require(evaluator.submittedDispatchCount == 1 && evaluator.lastCommandBufferStatus == Int(MTLCommandBufferStatus.completed.rawValue) && evaluator.lastCommandBufferError == nil,"GPU command did not complete exactly once")
    try require(gpu.v.count == points.count && gpu.grad.count == points.count,"GPU result shape mismatch")
    // These four CPU functions are copied verbatim from upstream FieldPotential.
    var directV = [Double](), directGradient = [Double](), lseV = [Double](), fdGradient = [Double]()
    var pv = Comparison(absoluteTolerance:1e-5,relativeTolerance:1e-4)
    var pg = Comparison(absoluteTolerance:1e-4,relativeTolerance:1e-3)
    var pl = Comparison(absoluteTolerance:1e-5,relativeTolerance:1e-4)
    var pf = Comparison(absoluteTolerance:1e-4,relativeTolerance:1e-3)
    for (i,p) in points.enumerated() {
        let v = FieldPotential.V(at:p,layout:layout,weights:weights,sigma:sigma)
        let g = FieldPotential.gradV(at:p,layout:layout,weights:weights,sigma:sigma)
        let l = FieldPotential.VLogSumExp(at:p,layout:layout,weights:weights,sigma:sigma)
        let f = FieldPotential.gradVLogSumExpFD(at:p,layout:layout,weights:weights,sigma:sigma)
        directV.append(v);directGradient.append(contentsOf:[g.x,g.y]);lseV.append(l);fdGradient.append(contentsOf:[f.x,f.y])
        pv.add(gpu.v[i],v);pg.add(gpu.grad[i].x,g.x);pg.add(gpu.grad[i].y,g.y)
        pl.add(v,l);pf.add(gpu.grad[i].x,f.x);pf.add(gpu.grad[i].y,f.y)
    }
    let payloads: [(String,Data,String,[Int])] = [
        ("gpu-potential.f32le",floats(gpu.v),"float32_little_endian",[200]),
        ("gpu-gradient.f32le",floats(gpu.grad.flatMap { [$0.x,$0.y] }),"float32_little_endian",[200,2]),
        ("cpu-potential.f64le",doubles(directV),"float64_little_endian",[200]),
        ("cpu-gradient.f64le",doubles(directGradient),"float64_little_endian",[200,2]),
        ("cpu-lse-potential.f64le",doubles(lseV),"float64_little_endian",[200]),
        ("cpu-lse-fd-gradient.f64le",doubles(fdGradient),"float64_little_endian",[200,2])]
    var artifacts = [[String:Any]]()
    for (name,data,dtype,shape) in payloads {
        try data.write(to:output.appendingPathComponent(name),options:.withoutOverwriting)
        artifacts.append(["path":name,"dtype":dtype,"shape":shape,"content":binding(data)])
    }
    let passed = [pv,pg,pl,pf].allSatisfy { $0.failures == 0 }
    let result: [String:Any] = ["schema":"prime_geometry_metal_comparison_v1","status":passed ? "PASS" : "FAIL",
        "execution":"host_Metal_compute_vs_original_CPU_formulas","modelRuns":0,"guestRuns":0,"virtualGPU":false,"cpuFallback":false,
        "device":["name":evaluator.deviceName,"registryID":evaluator.deviceRegistryID,"hasUnifiedMemory":evaluator.deviceHasUnifiedMemory],
        "pointCount":200,"nodeCount":12,"actualSubmittedDispatches":evaluator.submittedDispatchCount,"commandBufferStatus":evaluator.lastCommandBufferStatus!,"commandBufferError":NSNull(),
        "inputs":binding(inputData),"invalidInputChecks":checks,"artifacts":artifacts,"comparisons":["gpuPotentialVsCPUDirect":pv.json,"gpuGradientVsCPUDirect":pg.json,"CPUDirectPotentialVsLogSumExp":pl.json,"gpuGradientVsLogSumExpFiniteDifference":pf.json],
        "elapsedNanoseconds":DispatchTime.now().uptimeNanoseconds-started,"processID":getpid()]
    try encoded(result).write(to:output.appendingPathComponent("result.json"),options:.withoutOverwriting)
    print(String(data:try encoded(["status":passed ? "PASS" : "FAIL","pointCount":200,"dispatches":1,"invalidInputsRejected":checks.count,"result":output.appendingPathComponent("result.json").path]),encoding:.utf8)!)
    try require(passed,"GPU/CPU parity tolerance exceeded; original arrays retained")
}

@main private enum Main {
    static func main() {
        umask(0o077);alarm(60)
        var output: URL?
        do {
            let args = CommandLine.arguments
            try require(args.count == 3 && args[1] == "--output-directory" && args[2].hasPrefix("/"),"usage: GeometryMetalComparison --output-directory ABS_FRESH_DIRECTORY")
            let url = URL(fileURLWithPath:args[2],isDirectory:true)
            try require(url.standardizedFileURL.path == args[2] && url.deletingLastPathComponent().resolvingSymlinksInPath().path == url.deletingLastPathComponent().path,"output must be canonical with nonsymlink parent")
            try require(!FileManager.default.fileExists(atPath:url.path),"refuse existing output")
            try FileManager.default.createDirectory(at:url,withIntermediateDirectories:false,attributes:[.posixPermissions:0o700]);output=url
            try run(url);alarm(0)
        } catch {
            let record: [String:Any] = ["status":"ERROR","error":String(describing:error),"processID":getpid(),"modelRuns":0,"guestRuns":0]
            if let output, let data = try? encoded(record) { try? data.write(to:output.appendingPathComponent("error.json"),options:.withoutOverwriting) }
            FileHandle.standardError.write(Data(("Geometry Metal comparison: \(error)\n").utf8));exit(70)
        }
    }
}
