import Darwin
import Foundation

// This evaluates an explicitly supplied algebra expression using the unchanged
// AlgebraKit parser/evaluator. It does not interpret prose or invoke a model.
private enum Failure: Error { case arguments, unsupportedInput, nonFiniteResult }
alarm(10)
do {
    guard CommandLine.arguments.count == 3,
          CommandLine.arguments[1] == "--expression" else { throw Failure.arguments }
    let input = CommandLine.arguments[2]
    let allowed = Set("0123456789.+-*/() ".utf8)
    guard !input.isEmpty, input.utf8.count <= 128,
          input.utf8.allSatisfy({ allowed.contains($0) }) else { throw Failure.unsupportedInput }
    let expression = try ExprParser.parse(input)
    guard let value = expression.eval(x: 0), value.isFinite else { throw Failure.nonFiniteResult }
    let row: [String: Any] = [
        "schema": "prime_arithmetic_result_v1",
        "engine": "AlgebraKit.ExprParser + Expr.eval",
        "kind": "deterministic_expression_evaluation",
        "expression": input,
        "value": value,
        "renderedResult": String(format: "%.17g", value),
        "numericRepresentation": "Double; no general exact-rational claim",
        "kernelSourceSHA256": "7734702e1a7d77ca513d29ee81952560f5c5fa0af3d39fb8e883ac818ed01134",
        "checkpointUsed": false,
        "learnedTokenizerUsed": false,
        "trainingPerformed": false,
        "crossModelBinding": false,
        "inputTransform": "none; expression supplied explicitly"
    ]
    var data = try JSONSerialization.data(withJSONObject: row, options: [.sortedKeys, .withoutEscapingSlashes])
    data.append(10)
    try FileHandle.standardOutput.write(contentsOf: data)
} catch {
    fputs("Algebra expression failed: \(error)\n", stderr)
    exit(70)
}
