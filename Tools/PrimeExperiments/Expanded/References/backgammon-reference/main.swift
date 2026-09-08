import Foundation

let state = GameState(white: SideState([25: 1, 0: 14]),
                      black: SideState([6: 2, 0: 13]), currentPlayer: .white)
let roll = Roll(6, 3)
let legal = MoveGenerator.legalTurns(in: state, roll: roll)
guard legal == [Turn([.enterFromBar(to: 22), .point(from: 22, to: 16)])] else {
    fatalError("Unexpected original rules result")
}
var blockedEntryRejected = false
do {
    _ = try RulesEngine.apply(Turn([.enterFromBar(to: 19)]), roll: roll, to: state)
} catch RulesError.illegalTurn {
    blockedEntryRejected = true
}
guard blockedEntryRejected else { fatalError("Blocked entry was admitted") }
let after = try RulesEngine.apply(legal[0], roll: roll, to: state)
let result: [String: Any] = [
    "reference": "Original BackgammonKit rules, compiled without neural or UI code",
    "position": ["whiteOwnPipCounts": ["25": 1, "0": 14],
                 "blackOwnPipCounts": ["6": 2, "0": 13], "dice": [6, 3]],
    "legalTurns": legal.map { turn in
        turn.moves.map { ["origin": $0.origin, "destination": $0.destination, "die": $0.consumedDie] }
    },
    "blockedEntryRejected": blockedEntryRejected,
    "afterTurn": ["whiteAt16": after.white.count(at: 16), "whiteBar": after.white.bar,
                  "whiteOff": after.white.off, "turnPassed": after.currentPlayer == .black]
]
let bytes = try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
print(String(decoding: bytes, as: UTF8.self))
