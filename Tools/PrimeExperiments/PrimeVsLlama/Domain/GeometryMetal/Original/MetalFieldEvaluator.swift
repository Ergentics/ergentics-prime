//
//  MetalFieldEvaluator.swift  (MasteryFieldMetal — VDC Tier 2)
//
//  GPU compute evaluation of the Gaussian-well display potential V and analytic ∇V at
//  `renderingSigma`. Cross-checked against CPU `FieldPotential` in
//  EngineProposesMetalFieldParityTests (docs/masteryfield-gpu-field.md).
//
//  `init?` returns nil when there is no Metal device (CI Linux skips cleanly).
//

#if canImport(Metal)
import Metal
import simd

public final class MetalFieldEvaluator {

    public static let maxNodeCount = 64

    public struct GPUNode {
        public var pos: SIMD2<Float>
        public var weight: Float
        public var pad: Float = 0
    }

    public struct Evaluation: Sendable {
        public let v: [Double]
        public let grad: [SIMD2<Double>]
    }

    private let device: MTLDevice
    private let queue: MTLCommandQueue
    private let pipeline: MTLComputePipelineState

    public init?() {
        guard let dev = MTLCreateSystemDefaultDevice(),
              let q = dev.makeCommandQueue() else { return nil }
        do {
            let lib = try dev.makeLibrary(source: Self.shaderSource, options: nil)
            guard let fn = lib.makeFunction(name: "fieldEval") else { return nil }
            self.device = dev
            self.queue = q
            self.pipeline = try dev.makeComputePipelineState(function: fn)
        } catch {
            return nil
        }
    }

    /// Evaluate V and ∇V at each sample point via Metal compute (float32 parallel reduction).
    public func evaluate(points: [SIMD2<Double>],
                         nodes: [GPUNode],
                         sigma: Double) -> Evaluation? {
        guard !points.isEmpty, !nodes.isEmpty, nodes.count <= Self.maxNodeCount,
              sigma > 0, sigma.isFinite else { return nil }

        let ptF = points.map { SIMD2(Float($0.x), Float($0.y)) }
        var nodeCount = UInt32(nodes.count)
        var sigmaF = Float(sigma)

        guard let ptBuf = device.makeBuffer(bytes: ptF,
                                            length: ptF.count * MemoryLayout<SIMD2<Float>>.stride,
                                            options: .storageModeShared),
              let nodeBuf = device.makeBuffer(bytes: nodes,
                                              length: nodes.count * MemoryLayout<GPUNode>.stride,
                                              options: .storageModeShared),
              let sigmaBuf = device.makeBuffer(bytes: &sigmaF, length: MemoryLayout<Float>.stride,
                                               options: .storageModeShared),
              let countBuf = device.makeBuffer(bytes: &nodeCount, length: MemoryLayout<UInt32>.stride,
                                               options: .storageModeShared),
              let vBuf = device.makeBuffer(length: points.count * MemoryLayout<Float>.stride,
                                           options: .storageModeShared),
              let gBuf = device.makeBuffer(length: points.count * MemoryLayout<SIMD2<Float>>.stride,
                                           options: .storageModeShared),
              let cb = queue.makeCommandBuffer(),
              let enc = cb.makeComputeCommandEncoder() else { return nil }

        enc.setComputePipelineState(pipeline)
        enc.setBuffer(ptBuf, offset: 0, index: 0)
        enc.setBuffer(nodeBuf, offset: 0, index: 1)
        enc.setBuffer(sigmaBuf, offset: 0, index: 2)
        enc.setBuffer(countBuf, offset: 0, index: 3)
        enc.setBuffer(vBuf, offset: 0, index: 4)
        enc.setBuffer(gBuf, offset: 0, index: 5)

        let tg = MTLSize(width: 64, height: 1, depth: 1)
        let grid = MTLSize(width: points.count, height: 1, depth: 1)
        enc.dispatchThreads(grid, threadsPerThreadgroup: tg)
        enc.endEncoding()

#if os(macOS)
        if ptBuf.storageMode == .managed {
            if let blit = cb.makeBlitCommandEncoder() {
                blit.synchronize(resource: vBuf)
                blit.synchronize(resource: gBuf)
                blit.endEncoding()
            }
        }
#endif
        cb.commit()
        cb.waitUntilCompleted()

        let vPtr = vBuf.contents().bindMemory(to: Float.self, capacity: points.count)
        let gPtr = gBuf.contents().bindMemory(to: SIMD2<Float>.self, capacity: points.count)
        var vOut = [Double]()
        var gOut = [SIMD2<Double>]()
        vOut.reserveCapacity(points.count)
        gOut.reserveCapacity(points.count)
        for i in 0..<points.count {
            vOut.append(Double(vPtr[i]))
            gOut.append(SIMD2(Double(gPtr[i].x), Double(gPtr[i].y)))
        }
        return Evaluation(v: vOut, grad: gOut)
    }

    /// Build GPU node buffer from layout + weights (stable iteration order).
    public static func makeNodes(layout: [String: SIMD2<Double>],
                                 weights: [String: Double]) -> [GPUNode] {
        layout.keys.sorted().compactMap { id -> GPUNode? in
            guard let pos = layout[id] else { return nil }
            return GPUNode(pos: SIMD2(Float(pos.x), Float(pos.y)),
                           weight: Float(weights[id] ?? 0))
        }
    }

    private static let shaderSource = """
    #include <metal_stdlib>
    using namespace metal;

    struct GPUNode { float2 pos; float weight; float pad; };

    kernel void fieldEval(uint tid [[thread_position_in_grid]],
                          constant float2* points [[buffer(0)]],
                          constant GPUNode* nodes [[buffer(1)]],
                          constant float& sigma [[buffer(2)]],
                          constant uint& nodeCount [[buffer(3)]],
                          device float* outV [[buffer(4)]],
                          device float2* outGrad [[buffer(5)]]) {
        float s2 = sigma * sigma;
        float twoS2 = 2.0f * s2;
        float invS2 = 1.0f / s2;
        float2 p = points[tid];
        float sum = 0.0f;
        float2 grad = float2(0.0f, 0.0f);
        for (uint i = 0; i < nodeCount; i++) {
            float2 pi = nodes[i].pos;
            float w = nodes[i].weight;
            float2 d = p - pi;
            float r2 = dot(d, d);
            float g = exp(-r2 / twoS2);
            sum += w * g;
            float coeff = w * g * invS2;
            grad += float2(coeff * d.x, coeff * d.y);
        }
        outV[tid] = -sum;
        outGrad[tid] = grad;
    }
    """
}
#endif
