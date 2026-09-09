import AppKit
import Foundation

/// Opt-in signed-app integration check. Calls the same model actions as the
/// controls, retains real service outputs, and never supplies target answers.
@MainActor
enum PrimeComputeCheck {
    private static var started = false
    static func runOnce() async {
        guard !started else {return};started=true
        let model=PrimeComputeModel.shared
        var records=[[String:String]]()
        var errorMessage:String?
        let deadline=Task {try? await Task.sleep(for:.seconds(90));if !Task.isCancelled {model.cancel()}}
        let startedAt=ProcessInfo.processInfo.systemUptime
        func retain(_ name:String) throws {
            guard let report=model.report,model.failure == nil,!model.busy else {
                throw PrimeRuntimeFailure(message:model.failure ?? "App action did not complete: \(name)")
            }
            records.append(["case":name,"session":report.session.path,"title":report.title])
        }
        do {
            for variant in 0...1 {
                model.input = variant == 0 ? PrimeStudyInput() : PrimeStudyInput(left:.init(domain:1,readiness:3,durability:1),right:.init(domain:3,readiness:1,durability:2))
                for seed in ["1618","2718","3141"] {
                    for route in ["host","guest"] {
                        guard ProcessInfo.processInfo.systemUptime-startedAt < 90 else {throw PrimeRuntimeFailure(message:"App check deadline reached")}
                        model.seed=seed;model.execution=route
                        guard let task=model.runModel() else {throw PrimeRuntimeFailure(message:"Model action not admitted")}
                        await task.value;try retain("model-\(variant)-\(seed)-\(route)")
                    }
                }
            }
            model.nodes="[[0,0,1]]";model.sigma=0.5
            for variant in 0...1 {
                model.points=variant == 0 ? "[[0,0],[0.5,0]]" : "[[0.25,0.25],[1,0]]"
                for route in ["host","guest"] {
                    guard ProcessInfo.processInfo.systemUptime-startedAt < 90 else {throw PrimeRuntimeFailure(message:"App check deadline reached")}
                    model.execution=route
                    guard let task=model.runGeometry() else {throw PrimeRuntimeFailure(message:"Geometry action not admitted")}
                    await task.value;try retain("geometry-\(variant)-\(route)")
                }
            }
        } catch {errorMessage=error.localizedDescription}
        deadline.cancel()
        do {
            let support=try FileManager.default.url(for:.applicationSupportDirectory,in:.userDomainMask,appropriateFor:nil,create:true)
            let directory=support.appendingPathComponent("PrimeComputeChecks")
            try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:true,attributes:[.posixPermissions:0o700])
            let url=directory.appendingPathComponent(UUID().uuidString+".json")
            let result:[String:Any] = ["status":errorMessage == nil ? "completed" : "failed","error":errorMessage ?? "","appProcessID":ProcessInfo.processInfo.processIdentifier,"appBuild":Bundle.main.object(forInfoDictionaryKey:"CFBundleVersion") as? String ?? "unknown","appPath":Bundle.main.bundleURL.path,"runs":records,"elapsedSeconds":ProcessInfo.processInfo.systemUptime-startedAt,"trainingPerformed":false,"visualUIVerified":false]
            let data=try JSONSerialization.data(withJSONObject:result,options:[.sortedKeys,.prettyPrinted])
            try data.write(to:url,options:.withoutOverwriting)
            let receipt=try JSONSerialization.data(withJSONObject:["status":result["status"]!,"receipt":url.path],options:.sortedKeys)
            FileHandle.standardOutput.write(receipt+Data([10]))
        } catch {FileHandle.standardError.write(Data("Prime app check could not retain its receipt: \(error)\n".utf8));Darwin.exit(74)}
        Darwin.exit(errorMessage == nil ? 0 : 70)
    }
}
