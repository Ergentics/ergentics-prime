import Foundation

let state = GameState(one: SideState(boardIndices: [6]),
                      two: SideState(boardIndices: [8]), currentPlayer: .one)
let legal = MoveGenerator.legalMoves(in: state, roll: 2)
guard legal == [.enter(to: 2)] else { fatalError("Unexpected original rules result") }
var rosetteCaptureRejected = false
do {
    _ = try RulesEngine.apply(.advance(from: 6, to: 8), roll: 2, to: state)
} catch RulesError.illegalMove {
    rosetteCaptureRejected = true
}
guard rosetteCaptureRejected else { fatalError("Safe rosette move was admitted") }
let after = try RulesEngine.apply(legal[0], roll: 2, to: state)
var histogram = [Int](repeating: 0, count: 5)
for pattern in 0..<16 {
    histogram[Dice.total(of: (0..<4).map { pattern & (1 << $0) != 0 })] += 1
}
guard histogram == [1, 4, 6, 4, 1] else { fatalError("Dice enumeration changed") }
let result: [String: Any] = [
    "reference": "Original UrKit rules, compiled without model or UI code",
    "position": ["oneBoard": [6], "oneHome": 6, "oneOff": 0,
                 "twoBoard": [8], "twoHome": 6, "twoOff": 0, "roll": 2],
    "legalMoves": legal.map { ["origin": $0.origin, "destination": $0.destination] },
    "safeRosetteCaptureRejected": rosetteCaptureRejected,
    "afterEntry": ["oneBoard": after.one.boardIndices.sorted(), "oneHome": after.one.homeCount,
                   "opponentBoard": after.two.boardIndices.sorted(), "turnPassed": after.currentPlayer == .two],
    "exhaustiveFourDiceHistogram": histogram
]
let bytes = try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
print(String(decoding: bytes, as: UTF8.self))
