import SwiftUI

struct PrimeComputeView: View {
    @ObservedObject var model: PrimeComputeModel
    @State private var operation = 0
    var body: some View {
        ScrollView {
            VStack(alignment:.leading,spacing:20) {
                HStack(alignment:.top) {
                    VStack(alignment:.leading,spacing:6) {
                        Text("Prime").font(.largeTitle.bold())
                        Text("Run your model and GPU services on this Mac.").foregroundStyle(.secondary)
                    }
                    Spacer()
                    Label("Local",systemImage:"desktopcomputer").foregroundStyle(.teal)
                }
                Picker("Service",selection:$operation) {
                    Text("Learned study strategy").tag(0)
                    Text("Geometry field").tag(1)
                }.pickerStyle(.segmented).disabled(model.busy)
                    .accessibilityIdentifier("prime.compute.service")
                HStack {
                    Picker("Execution",selection:$model.execution) {
                        Text("Guest → Metal").tag("guest")
                        Text("Host → Metal").tag("host")
                    }.frame(maxWidth:300)
                    if operation == 0 {
                        Picker("Checkpoint",selection:$model.seed) {
                            ForEach(["1618","2718","3141"],id:\.self) {Text("Prime · seed \($0)").tag($0)}
                        }.frame(maxWidth:250)
                    }
                    Spacer()
                }.disabled(model.busy)
                if operation == 0 { studyInputs } else { geometryInputs }
                HStack {
                    Button(operation == 0 ? "Ask Prime" : "Compute field") {
                        if operation == 0 {model.runModel()} else {model.runGeometry()}
                    }.buttonStyle(.borderedProminent).disabled(model.busy)
                        .keyboardShortcut(.return,modifiers:.command)
                        .accessibilityIdentifier("prime.compute.run")
                    if model.busy {ProgressView().controlSize(.small);Button("Stop"){model.cancel()}}
                    Text(model.status).font(.callout).foregroundStyle(.secondary)
                        .accessibilityIdentifier("prime.compute.status")
                    Spacer()
                }
                if let failure=model.failure {
                    Text(failure).foregroundStyle(.red).textSelection(.enabled)
                        .accessibilityIdentifier("prime.compute.error")
                }
                Divider()
                VStack(alignment:.leading,spacing:12) {
                    Text(model.report?.title ?? "Result").font(.headline)
                    Text(model.report?.detail ?? "Change the inputs, then run the selected service. Results come directly from the bundled Prime runtime.")
                        .font(.system(.body,design:model.report == nil ? .default : .monospaced))
                        .foregroundStyle(model.report == nil ? .secondary : .primary)
                        .textSelection(.enabled).frame(maxWidth:.infinity,alignment:.leading)
                        .accessibilityIdentifier("prime.compute.result")
                    if let report=model.report {
                        HStack {
                            Text(String(format:"%.3f seconds · inputs and raw results saved",report.elapsedSeconds))
                                .font(.caption).foregroundStyle(.secondary)
                            Spacer()
                            Button("Show saved run"){model.revealSession()}
                            Button("Export result…"){model.saveResult()}
                        }
                    }
                }.padding(18).background(.quaternary.opacity(0.35),in:RoundedRectangle(cornerRadius:12))
                Text("The guest controls requests and receives results; the Mac’s GPU performs the computation. Model inference and geometry are separate services in this app.")
                    .font(.caption).foregroundStyle(.secondary)
            }.padding(28)
        }.frame(minWidth:640,minHeight:620)
    }

    private var studyInputs: some View {
        VStack(alignment:.leading,spacing:14) {
            Text("Which candidate and study strategy does Prime predict?").font(.title3.weight(.semibold))
            Text("Retained Prime domain model · 10.2M parameters · original trained token scheme")
                .font(.callout).foregroundStyle(.secondary)
            HStack(alignment:.top,spacing:16) {
                candidate("Left candidate",value:$model.input.left)
                candidate("Right candidate",value:$model.input.right)
            }.disabled(model.busy)
            Text(model.input.scopeNote).font(.caption).foregroundStyle(.secondary)
            Text("This checkpoint learned a structured study-policy task. It does not encode arbitrary English questions.")
                .font(.caption).foregroundStyle(.secondary)
        }
    }
    private func candidate(_ title:String,value:Binding<PrimeStudyCandidate>) -> some View {
        GroupBox(title) {
            VStack(alignment:.leading,spacing:12) {
                Picker("Domain",selection:value.domain) {
                    ForEach(PrimeStudyInput.domainLabels.indices,id:\.self) {i in Text(PrimeStudyInput.domainLabels[i]).tag(i)}
                }
                Picker("Readiness",selection:value.readiness) {
                    ForEach(PrimeStudyInput.readinessValues.indices,id:\.self) {i in Text(String(format:"%.2f",PrimeStudyInput.readinessValues[i])).tag(i)}
                }
                Picker("Durability",selection:value.durability) {
                    ForEach(PrimeStudyInput.durabilityValues.indices,id:\.self) {i in Text(String(format:"%.2f",PrimeStudyInput.durabilityValues[i])).tag(i)}
                }
            }.padding(8)
        }.frame(maxWidth:.infinity)
    }
    private var geometryInputs: some View {
        VStack(alignment:.leading,spacing:12) {
            Text("Potential and gradient at your points").font(.title3.weight(.semibold))
            Text("geometry-app’s Metal field kernel, with numeric results returned to Prime.").foregroundStyle(.secondary)
            Text("Points · [x, y]").font(.headline)
            TextEditor(text:$model.points).font(.system(.body,design:.monospaced)).frame(height:70)
                .accessibilityIdentifier("prime.compute.points")
            Text("Nodes · [x, y, weight]").font(.headline)
            TextEditor(text:$model.nodes).font(.system(.body,design:.monospaced)).frame(height:70)
                .accessibilityIdentifier("prime.compute.nodes")
            TextField("Width (sigma)",value:$model.sigma,format:.number).frame(maxWidth:220)
        }.disabled(model.busy)
    }
}
