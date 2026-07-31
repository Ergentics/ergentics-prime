import Foundation

struct PrimeNativeNeuralGatePromptSolverGrammar {
    private static let maximumNonemptyLineCount = 64
    private static let maximumActionLineCount = 32
    private static let maximumRelationEdgeCount = 32

    private let scalarOpenings:
        [NSRegularExpression]
    private let transferOpenings:
        [NSRegularExpression]
    private let add:
        NSRegularExpression
    private let subtract:
        NSRegularExpression
    private let negate:
        NSRegularExpression
    private let undoScalar:
        NSRegularExpression
    private let move:
        NSRegularExpression
    private let swap:
        NSRegularExpression
    private let placeBefore:
        NSRegularExpression
    private let relation:
        NSRegularExpression
    private let scalarQuestions:
        [NSRegularExpression]
    private let entityHoldingQuestions:
        [NSRegularExpression]
    private let immediatelyBeforeQuestion:
        NSRegularExpression
    private let beforeQuestion:
        NSRegularExpression
    private let positionQuestion:
        NSRegularExpression
    private let distanceQuestion:
        NSRegularExpression
    private let notRightQuestion:
        NSRegularExpression
    private let codebooks:
        [PrimeNativeNeuralGatePromptSolverCodebook]

    init() throws {
        scalarOpenings = try Self.compile([
            #"^Initially, ([a-z0-9_]+) has value (-?[0-9]+)\.$"#,
            #"^At the start, ([a-z0-9_]+)'s reading is (-?[0-9]+)\.$"#,
            #"^The opening value of ([a-z0-9_]+) is (-?[0-9]+)\.$"#,
            #"^Begin with ([a-z0-9_]+) at (-?[0-9]+)\.$"#,
            #"^The record opens with ([a-z0-9_]+) at (-?[0-9]+)\.$"#,
        ])
        transferOpenings = try Self.compile([
            #"^Initially, ([a-z0-9_]+) holds (-?[0-9]+); ([a-z0-9_]+) holds (-?[0-9]+); ([a-z0-9_]+) holds (-?[0-9]+)\.$"#,
            #"^At the start, ([a-z0-9_]+) holds (-?[0-9]+); ([a-z0-9_]+) holds (-?[0-9]+); ([a-z0-9_]+) holds (-?[0-9]+)\.$"#,
            #"^The opening ledger says ([a-z0-9_]+) holds (-?[0-9]+); ([a-z0-9_]+) holds (-?[0-9]+); ([a-z0-9_]+) holds (-?[0-9]+)\.$"#,
            #"^Begin with ([a-z0-9_]+) holds (-?[0-9]+); ([a-z0-9_]+) holds (-?[0-9]+); ([a-z0-9_]+) holds (-?[0-9]+)\.$"#,
            #"^The record opens: ([a-z0-9_]+) holds (-?[0-9]+); ([a-z0-9_]+) holds (-?[0-9]+); ([a-z0-9_]+) holds (-?[0-9]+)\.$"#,
        ])
        add = try Self.compile(
            #"^add ([0-9]+) to ([a-z0-9_]+)\.$"#
        )
        subtract = try Self.compile(
            #"^subtract ([0-9]+) from ([a-z0-9_]+)\.$"#
        )
        negate = try Self.compile(
            #"^negate ([a-z0-9_]+)\.$"#
        )
        undoScalar = try Self.compile(
            #"^undo the previous change to ([a-z0-9_]+)\.$"#
        )
        move = try Self.compile(
            #"^move ([0-9]+) from ([a-z0-9_]+) to ([a-z0-9_]+)\.$"#
        )
        swap = try Self.compile(
            #"^swap ([a-z0-9_]+) with ([a-z0-9_]+)\.$"#
        )
        placeBefore = try Self.compile(
            #"^place ([a-z0-9_]+) immediately before ([a-z0-9_]+)\.$"#
        )
        relation = try Self.compile(
            #"^([a-z0-9_]+) is ([0-9]+) steps (right|left) of ([a-z0-9_]+)\.$"#
        )
        scalarQuestions = try Self.compile([
            #"^What is the final value of ([a-z0-9_]+)\?$"#,
            #"^Return the final reading of ([a-z0-9_]+)\.$"#,
            #"^Report the terminal value of ([a-z0-9_]+)\.$"#,
            #"^Give the ending value of ([a-z0-9_]+)\.$"#,
            #"^Determine the final value of ([a-z0-9_]+)\.$"#,
        ])
        entityHoldingQuestions = try Self.compile([
            #"^What does ([a-z0-9_]+) finally hold\?$"#,
            #"^Return the final holding of ([a-z0-9_]+)\.$"#,
            #"^Report ([a-z0-9_]+)'s terminal holding\.$"#,
            #"^Give the ending holding of ([a-z0-9_]+)\.$"#,
            #"^Determine the final holding of ([a-z0-9_]+)\.$"#,
        ])
        immediatelyBeforeQuestion = try Self.compile(
            #"^Which item is immediately before ([a-z0-9_]+)\?$"#
        )
        beforeQuestion = try Self.compile(
            #"^Is ([a-z0-9_]+) before ([a-z0-9_]+)\?$"#
        )
        positionQuestion = try Self.compile(
            #"^What is the one-based position of ([a-z0-9_]+)\?$"#
        )
        distanceQuestion = try Self.compile(
            #"^What is the signed distance from ([a-z0-9_]+) to ([a-z0-9_]+)\?$"#
        )
        notRightQuestion = try Self.compile(
            #"^Is ([a-z0-9_]+) not right of ([a-z0-9_]+)\?$"#
        )
        codebooks = [
            PrimeNativeNeuralGatePromptSolverCodebook(
                entityNames: [
                    "amber", "birch", "cobalt", "dune",
                    "ember", "flint", "grove", "harbor",
                ]
            ),
            PrimeNativeNeuralGatePromptSolverCodebook(
                entityNames: [
                    "atlas", "beacon", "coral", "drift",
                    "estuary", "fjord", "gale", "haven",
                ]
            ),
            PrimeNativeNeuralGatePromptSolverCodebook(
                entityNames: [
                    "ion", "jade", "kite", "lumen",
                    "mica", "nova", "opal", "quartz",
                ]
            ),
            PrimeNativeNeuralGatePromptSolverCodebook(
                entityNames: [
                    "aster", "brin", "cassia", "dorun",
                    "elara", "fen", "galen", "hyra",
                ]
            ),
            PrimeNativeNeuralGatePromptSolverCodebook(
                entityNames: [
                    "axiom", "boson", "chirp", "dynamo",
                    "epoch", "flux", "gluon", "helix",
                ]
            ),
        ]
    }

    func solve(_ prompt: String) -> String? {
        guard prompt
                == prompt
                .precomposedStringWithCanonicalMapping
        else {
            return nil
        }
        let splitLines = prompt.split(
            separator: "\n",
            omittingEmptySubsequences: false
        ).map(String.init)
        guard splitLines.last == "",
              splitLines.dropLast().allSatisfy({
                  !$0.isEmpty
              })
        else {
            return nil
        }
        let lines = Array(splitLines.dropLast())
        guard (3 ... Self.maximumNonemptyLineCount)
                .contains(lines.count),
              lines.last == "Answer:"
        else {
            return nil
        }

        let contentLines = Array(lines.dropLast())
        var questionIndex: Int?
        var questionCount = 0
        for index in contentLines.indices {
            if questionLike(contentLines[index]) {
                let (
                    nextCount,
                    overflow
                ) = questionCount
                    .addingReportingOverflow(1)
                guard !overflow else {
                    return nil
                }
                questionCount = nextCount
                questionIndex = index
            }
        }
        guard questionCount == 1,
              let resolvedQuestionIndex =
                questionIndex,
              resolvedQuestionIndex
                == contentLines.index(
                    before: contentLines.endIndex
                ),
              let opening = contentLines.first
        else {
            return nil
        }
        let question =
            contentLines[resolvedQuestionIndex]
        let actions = Array(
            contentLines.dropFirst().dropLast()
        )
        guard (1 ... Self.maximumActionLineCount)
                .contains(actions.count),
              let openingContract =
                openingContract(opening),
              let actionStyle =
                validatedActionStyle(
                    actions,
                    allowed:
                        openingContract
                        .allowedActionStyles
                ),
              questionIsValid(
                  question,
                  for: actionStyle,
                  family: openingContract.family
              )
        else {
            return nil
        }

        let resolution:
            PrimeNativeNeuralGatePromptSolverResolution?
        switch openingContract.family {
        case .relation:
            resolution = parseRelation(
                actions: actions,
                question: question
            )
        case .ordering:
            resolution = parseOrdering(
                opening: opening,
                actions: actions,
                question: question
            )
        case .transfer:
            resolution = parseTransfer(
                opening: opening,
                actions: actions,
                question: question
            )
        case .scalar:
            resolution = parseScalar(
                opening: opening,
                actions: actions,
                question: question
            )
        }
        guard let resolution else {
            return nil
        }
        return resolution.answer.display(
            using: resolution.codebook
        )
    }

    private func openingContract(
        _ opening: String
    ) -> PrimeNativeNeuralGatePromptSolverOpeningContract? {
        if firstCaptures(
            scalarOpenings,
            in: opening
        ) != nil,
           let style = surfaceStyle(
               for: opening
           )
        {
            return PrimeNativeNeuralGatePromptSolverOpeningContract(
                family: .scalar,
                allowedActionStyles: [style]
            )
        }
        if firstCaptures(
            transferOpenings,
            in: opening
        ) != nil,
           let style = surfaceStyle(
               for: opening
           )
        {
            return PrimeNativeNeuralGatePromptSolverOpeningContract(
                family: .transfer,
                allowedActionStyles: [style]
            )
        }
        if orderingOpeningIsCanonical(opening),
           let style = surfaceStyle(
               for: opening
           )
        {
            return PrimeNativeNeuralGatePromptSolverOpeningContract(
                family: .ordering,
                allowedActionStyles: [style]
            )
        }
        if opening == "The record contains these relations." {
            return PrimeNativeNeuralGatePromptSolverOpeningContract(
                family: .relation,
                allowedActionStyles: [.record]
            )
        }
        if opening == "Use these relations." {
            return PrimeNativeNeuralGatePromptSolverOpeningContract(
                family: .relation,
                allowedActionStyles: [
                    .initial,
                    .start,
                    .opening,
                    .begin,
                ]
            )
        }
        return nil
    }

    private func orderingOpeningIsCanonical(
        _ opening: String
    ) -> Bool {
        let prefixes = [
            "Initially, the order is ",
            "At the start, the order is ",
            "The opening order is ",
            "Begin with the order ",
            "The record opens in order: ",
        ]
        guard let prefix = prefixes.first(
            where: {
                opening.hasPrefix($0)
            }
        ),
              opening.hasSuffix("."),
              let terminal = opening.indices.last
        else {
            return false
        }
        let contentStart = opening.index(
            opening.startIndex,
            offsetBy: prefix.count
        )
        guard contentStart < terminal else {
            return false
        }
        let names = String(
            opening[contentStart ..< terminal]
        ).components(
            separatedBy: " before "
        )
        guard names.count == 5,
              Set(names).count == names.count
        else {
            return false
        }
        return names.allSatisfy {
            $0.range(
                of: #"^[a-z0-9_]+$"#,
                options: .regularExpression
            ) != nil
        }
    }

    private func surfaceStyle(
        for opening: String
    ) -> PrimeNativeNeuralGatePromptSolverActionStyle? {
        if opening.hasPrefix("Initially, ") {
            return .initial
        }
        if opening.hasPrefix("At the start, ") {
            return .start
        }
        if opening.hasPrefix("The opening ") {
            return .opening
        }
        if opening.hasPrefix("Begin with ") {
            return .begin
        }
        if opening.hasPrefix("The record opens") {
            return .record
        }
        return nil
    }

    private func validatedActionStyle(
        _ actions: [String],
        allowed:
            [PrimeNativeNeuralGatePromptSolverActionStyle]
    ) -> PrimeNativeNeuralGatePromptSolverActionStyle? {
        for style in allowed {
            var valid = true
            for (index, line) in actions.enumerated() {
                let expectedLead =
                    index == actions.startIndex
                        ? style.firstLead
                        : style.continuationLead
                guard line.hasPrefix(
                    expectedLead + ", "
                ) else {
                    valid = false
                    break
                }
            }
            if valid {
                return style
            }
        }
        return nil
    }

    private func questionIsValid(
        _ question: String,
        for style:
            PrimeNativeNeuralGatePromptSolverActionStyle,
        family:
            PrimeNativeNeuralGatePromptSolverFamily
    ) -> Bool {
        switch family {
        case .scalar:
            guard let expression = element(
                scalarQuestions,
                at: style.surfaceIndex
            ) else {
                return false
            }
            return captures(
                expression,
                in: question
            ) != nil
        case .transfer:
            if let expression = element(
                entityHoldingQuestions,
                at: style.surfaceIndex
            ),
               captures(
                   expression,
                   in: question
               ) != nil
            {
                return true
            }
            let totalQuestions = [
                "What is the final total?",
                "Return the final total.",
                "Report the terminal total.",
                "Give the ending total.",
                "Determine the final total.",
            ]
            guard let expected = element(
                totalQuestions,
                at: style.surfaceIndex
            ) else {
                return false
            }
            return question == expected
        case .ordering, .relation:
            return true
        }
    }

    private func parseScalar(
        opening: String,
        actions: [String],
        question: String
    ) -> PrimeNativeNeuralGatePromptSolverResolution? {
        guard let openingValues =
            firstCaptures(
                scalarOpenings,
                in: opening
            ),
              openingValues.count == 2,
              let name = openingValues.first,
              let initialText = openingValues.last,
              let initial = Int(initialText),
              let codebook = codebook(
                  containing: [name]
              ),
              let entitySlot = slot(
                  name,
                  codebook: codebook
              ),
              entitySlot == 0
        else {
            return nil
        }

        var value = initial
        var history:
            [PrimeNativeNeuralGatePromptSolverScalarOperation] =
            []
        for line in actions {
            guard let actionText = action(line)
            else {
                return nil
            }
            if let captures = captures(
                add,
                in: actionText
            ),
               captures.count == 2,
               let amount = captures.first
               .flatMap(Int.init),
               let entity = captures.last,
               slot(entity, codebook: codebook)
               == entitySlot
            {
                let (
                    next,
                    overflow
                ) = value.addingReportingOverflow(
                    amount
                )
                guard !overflow else {
                    return nil
                }
                value = next
                history.append(.add(amount))
            } else if let captures = captures(
                subtract,
                in: actionText
            ),
                      captures.count == 2,
                      let amount = captures.first
                      .flatMap(Int.init),
                      let entity = captures.last,
                      slot(
                          entity,
                          codebook: codebook
                      ) == entitySlot
            {
                let (
                    next,
                    overflow
                ) = value
                    .subtractingReportingOverflow(
                        amount
                    )
                guard !overflow else {
                    return nil
                }
                value = next
                history.append(.subtract(amount))
            } else if let captures = captures(
                negate,
                in: actionText
            ),
                      captures.count == 1,
                      captures.first
                      .flatMap({
                          slot(
                              $0,
                              codebook: codebook
                          )
                      }) == entitySlot
            {
                let (
                    next,
                    overflow
                ) = 0
                    .subtractingReportingOverflow(
                        value
                    )
                guard !overflow else {
                    return nil
                }
                value = next
                history.append(.negate)
            } else if let captures = captures(
                undoScalar,
                in: actionText
            ),
                      captures.count == 1,
                      captures.first
                      .flatMap({
                          slot(
                              $0,
                              codebook: codebook
                          )
                      }) == entitySlot,
                      let previous = history.popLast()
            {
                guard let restored =
                    undoScalarOperation(
                        previous,
                        from: value
                    )
                else {
                    return nil
                }
                value = restored
            } else {
                return nil
            }
        }

        guard let queryValues = firstCaptures(
            scalarQuestions,
            in: question
        ),
              queryValues.count == 1,
              let queryName = queryValues.first,
              slot(
                  queryName,
                  codebook: codebook
              ) == entitySlot
        else {
            return nil
        }
        return PrimeNativeNeuralGatePromptSolverResolution(
            answer: .number(value),
            codebook: codebook
        )
    }

    private func undoScalarOperation(
        _ operation:
            PrimeNativeNeuralGatePromptSolverScalarOperation,
        from value: Int
    ) -> Int? {
        switch operation {
        case .add(let amount):
            let (
                restored,
                overflow
            ) = value.subtractingReportingOverflow(
                amount
            )
            return overflow ? nil : restored
        case .subtract(let amount):
            let (
                restored,
                overflow
            ) = value.addingReportingOverflow(
                amount
            )
            return overflow ? nil : restored
        case .negate:
            let (
                restored,
                overflow
            ) = 0.subtractingReportingOverflow(
                value
            )
            return overflow ? nil : restored
        }
    }

    private func parseTransfer(
        opening: String,
        actions: [String],
        question: String
    ) -> PrimeNativeNeuralGatePromptSolverResolution? {
        guard let openingValues =
            firstCaptures(
                transferOpenings,
                in: opening
            ),
              openingValues.count == 6
        else {
            return nil
        }
        var names: [String] = []
        var initialTexts: [String] = []
        names.reserveCapacity(3)
        initialTexts.reserveCapacity(3)
        var captureIndex = 0
        while captureIndex < openingValues.count {
            let (
                valueIndex,
                valueIndexOverflow
            ) = captureIndex.addingReportingOverflow(1)
            guard !valueIndexOverflow,
                  let name = element(
                      openingValues,
                      at: captureIndex
                  ),
                  let valueText = element(
                      openingValues,
                      at: valueIndex
                  )
            else {
                return nil
            }
            names.append(name)
            initialTexts.append(valueText)
            let (
                nextCaptureIndex,
                nextCaptureIndexOverflow
            ) = captureIndex.addingReportingOverflow(2)
            guard !nextCaptureIndexOverflow else {
                return nil
            }
            captureIndex = nextCaptureIndex
        }
        guard names.count == 3,
              initialTexts.count == names.count,
              Set(names).count == names.count,
              let codebook = codebook(
                  containing: names
              )
        else {
            return nil
        }
        var values: [Int] = []
        values.reserveCapacity(3)
        for (index, name) in names.enumerated() {
            guard let valueText = element(
                      initialTexts,
                      at: index
                  ),
                  slot(
                      name,
                      codebook: codebook
                  ) == index,
                  let value = Int(valueText)
            else {
                return nil
            }
            values.append(value)
        }

        var history:
            [PrimeNativeNeuralGatePromptSolverTransferOperation] =
            []
        for line in actions {
            guard let actionText = action(line)
            else {
                return nil
            }
            if let captures = captures(
                move,
                in: actionText
            ),
               captures.count == 3,
               let amountText = captures.first,
               let amount = Int(amountText),
               let sourceName =
               element(captures, at: 1),
               let destinationName = captures.last,
               let source = slot(
                   sourceName,
                   codebook: codebook
               ),
               let destination = slot(
                   destinationName,
                   codebook: codebook
               ),
               amount > 0,
               values.indices.contains(source),
               values.indices.contains(destination),
               source != destination
            {
                guard let moved = moveValue(
                    amount: amount,
                    source: source,
                    destination: destination,
                    values: values
                ) else {
                    return nil
                }
                values = moved
                history.append(
                    .move(
                        amount: amount,
                        source: source,
                        destination: destination
                    )
                )
            } else if actionText
                == "undo the previous transfer.",
                      let previous = history.popLast(),
                      let restored = undoTransfer(
                          previous,
                          values: values
                      )
            {
                values = restored
            } else {
                return nil
            }
        }

        let answer: Int
        if [
            "What is the final total?",
            "Return the final total.",
            "Report the terminal total.",
            "Give the ending total.",
            "Determine the final total.",
        ].contains(question) {
            guard let total = checkedSum(values)
            else {
                return nil
            }
            answer = total
        } else if let queryValues =
            firstCaptures(
                entityHoldingQuestions,
                in: question
            ),
                  queryValues.count == 1,
                  let name = queryValues.first,
                  let entity = slot(
                      name,
                      codebook: codebook
                  ),
                  let held = element(
                      values,
                      at: entity
                  )
        {
            answer = held
        } else {
            return nil
        }
        return PrimeNativeNeuralGatePromptSolverResolution(
            answer: .number(answer),
            codebook: codebook
        )
    }

    private func moveValue(
        amount: Int,
        source: Int,
        destination: Int,
        values: [Int]
    ) -> [Int]? {
        guard let sourceValue = element(
            values,
            at: source
        ),
              let destinationValue = element(
                  values,
                  at: destination
              )
        else {
            return nil
        }
        let (
            nextSource,
            sourceOverflow
        ) = sourceValue
            .subtractingReportingOverflow(amount)
        let (
            nextDestination,
            destinationOverflow
        ) = destinationValue
            .addingReportingOverflow(amount)
        guard !sourceOverflow,
              !destinationOverflow
        else {
            return nil
        }
        var result = values
        result[source] = nextSource
        result[destination] = nextDestination
        return result
    }

    private func undoTransfer(
        _ operation:
            PrimeNativeNeuralGatePromptSolverTransferOperation,
        values: [Int]
    ) -> [Int]? {
        switch operation {
        case .move(
            let amount,
            let source,
            let destination
        ):
            guard let sourceValue = element(
                values,
                at: source
            ),
                  let destinationValue = element(
                      values,
                      at: destination
                  )
            else {
                return nil
            }
            let (
                restoredSource,
                sourceOverflow
            ) = sourceValue
                .addingReportingOverflow(amount)
            let (
                restoredDestination,
                destinationOverflow
            ) = destinationValue
                .subtractingReportingOverflow(
                    amount
                )
            guard !sourceOverflow,
                  !destinationOverflow
            else {
                return nil
            }
            var result = values
            result[source] = restoredSource
            result[destination] =
                restoredDestination
            return result
        }
    }

    private func parseOrdering(
        opening: String,
        actions: [String],
        question: String
    ) -> PrimeNativeNeuralGatePromptSolverResolution? {
        let prefixes = [
            "Initially, the order is ",
            "At the start, the order is ",
            "The opening order is ",
            "Begin with the order ",
            "The record opens in order: ",
        ]
        guard let prefix = prefixes.first(
            where: {
                opening.hasPrefix($0)
            }
        ),
              opening.hasSuffix("."),
              let terminal = opening.indices.last
        else {
            return nil
        }
        let contentStart = opening.index(
            opening.startIndex,
            offsetBy: prefix.count
        )
        guard contentStart <= terminal else {
            return nil
        }
        let orderText = String(
            opening[contentStart ..< terminal]
        )
        let names = orderText.components(
            separatedBy: " before "
        )
        guard names.count == 5,
              Set(names).count == names.count,
              let codebook = codebook(
                  containing: names
              )
        else {
            return nil
        }
        let initial = names.compactMap {
            slot($0, codebook: codebook)
        }
        guard initial.count == names.count
        else {
            return nil
        }
        var order = initial
        var history: [[Int]] = []
        for line in actions {
            guard let actionText = action(line)
            else {
                return nil
            }
            if let captures = captures(
                swap,
                in: actionText
            ),
               captures.count == 2,
               let leftName = captures.first,
               let rightName = captures.last,
               let left = slot(
                   leftName,
                   codebook: codebook
               ),
               let right = slot(
                   rightName,
                   codebook: codebook
               ),
               left != right,
               let leftIndex = order
               .firstIndex(of: left),
               let rightIndex = order
               .firstIndex(of: right)
            {
                history.append(order)
                order.swapAt(
                    leftIndex,
                    rightIndex
                )
            } else if let captures = captures(
                placeBefore,
                in: actionText
            ),
                      captures.count == 2,
                      let movedName = captures.first,
                      let anchorName = captures.last,
                      let moved = slot(
                          movedName,
                          codebook: codebook
                      ),
                      let anchor = slot(
                          anchorName,
                          codebook: codebook
                      ),
                      moved != anchor,
                      let movedIndex = order
                      .firstIndex(of: moved),
                      order.contains(anchor)
            {
                let prior = order
                order.remove(at: movedIndex)
                guard let anchorIndex = order
                    .firstIndex(of: anchor)
                else {
                    return nil
                }
                history.append(prior)
                order.insert(
                    moved,
                    at: anchorIndex
                )
            } else if actionText
                == "reverse the complete order."
            {
                history.append(order)
                order.reverse()
            } else if actionText
                == "undo the previous ordering change.",
                      let prior = history.popLast()
            {
                order = prior
            } else {
                return nil
            }
        }

        let answer:
            PrimeNativeNeuralGatePromptSolverAnswer
        if let queryValues = captures(
            immediatelyBeforeQuestion,
            in: question
        ),
           queryValues.count == 1,
           let name = queryValues.first,
           let entity = slot(
               name,
               codebook: codebook
           ),
           let index = order.firstIndex(
               of: entity
           )
        {
            if index == order.startIndex {
                answer = .entity(nil)
            } else {
                answer = .entity(
                    element(
                        order,
                        at: index - 1
                    )
                )
            }
        } else if let queryValues = captures(
            beforeQuestion,
            in: question
        ),
                  queryValues.count == 2,
                  let leftName = queryValues.first,
                  let rightName = queryValues.last,
                  let left = slot(
                      leftName,
                      codebook: codebook
                  ),
                  let right = slot(
                      rightName,
                      codebook: codebook
                  ),
                  let leftIndex = order
                  .firstIndex(of: left),
                  let rightIndex = order
                  .firstIndex(of: right)
        {
            answer = .boolean(
                leftIndex < rightIndex
            )
        } else if let queryValues = captures(
            positionQuestion,
            in: question
        ),
                  queryValues.count == 1,
                  let name = queryValues.first,
                  let entity = slot(
                      name,
                      codebook: codebook
                  ),
                  let index = order
                  .firstIndex(of: entity)
        {
            let (
                position,
                overflow
            ) = index.addingReportingOverflow(1)
            guard !overflow else {
                return nil
            }
            answer = .number(position)
        } else {
            return nil
        }
        return PrimeNativeNeuralGatePromptSolverResolution(
            answer: answer,
            codebook: codebook
        )
    }

    private func parseRelation(
        actions: [String],
        question: String
    ) -> PrimeNativeNeuralGatePromptSolverResolution? {
        guard actions.count
                <= Self.maximumRelationEdgeCount
        else {
            return nil
        }
        var rawEdges: [
            (
                from: String,
                to: String,
                delta: Int
            )
        ] = []
        rawEdges.reserveCapacity(actions.count)
        for line in actions {
            guard let actionText = action(line),
                  let captures = captures(
                      relation,
                      in: actionText
                  ),
                  captures.count == 4,
                  let toName = captures.first,
                  let magnitudeText =
                  element(captures, at: 1),
                  let direction =
                  element(captures, at: 2),
                  let fromName = captures.last,
                  let magnitude =
                  Int(magnitudeText)
            else {
                return nil
            }
            let delta: Int
            if direction == "right" {
                delta = magnitude
            } else if direction == "left" {
                let (
                    negative,
                    overflow
                ) = 0
                    .subtractingReportingOverflow(
                        magnitude
                    )
                guard !overflow else {
                    return nil
                }
                delta = negative
            } else {
                return nil
            }
            rawEdges.append(
                (
                    from: fromName,
                    to: toName,
                    delta: delta
                )
            )
        }
        let names = rawEdges.flatMap {
            [$0.from, $0.to]
        }
        guard let codebook = codebook(
            containing: names
        ) else {
            return nil
        }
        var edges: [
            (
                from: Int,
                to: Int,
                delta: Int
            )
        ] = []
        edges.reserveCapacity(rawEdges.count)
        for edge in rawEdges {
            guard let from = slot(
                edge.from,
                codebook: codebook
            ),
                  let to = slot(
                      edge.to,
                      codebook: codebook
                  )
            else {
                return nil
            }
            edges.append(
                (
                    from: from,
                    to: to,
                    delta: edge.delta
                )
            )
        }
        guard let coordinates =
            relationCoordinates(edges)
        else {
            return nil
        }

        let answer:
            PrimeNativeNeuralGatePromptSolverAnswer
        if let queryValues = captures(
            distanceQuestion,
            in: question
        ),
           queryValues.count == 2,
           let sourceName = queryValues.first,
           let destinationName = queryValues.last,
           let source = slot(
               sourceName,
               codebook: codebook
           ),
           let destination = slot(
               destinationName,
               codebook: codebook
           ),
           let sourceValue = coordinates[source],
           let destinationValue =
           coordinates[destination]
        {
            let (
                distance,
                overflow
            ) = destinationValue
                .subtractingReportingOverflow(
                    sourceValue
                )
            guard !overflow else {
                return nil
            }
            answer = .number(distance)
        } else if let queryValues = captures(
            notRightQuestion,
            in: question
        ),
                  queryValues.count == 2,
                  let leftName = queryValues.first,
                  let rightName = queryValues.last,
                  let left = slot(
                      leftName,
                      codebook: codebook
                  ),
                  let right = slot(
                      rightName,
                      codebook: codebook
                  ),
                  let leftValue = coordinates[left],
                  let rightValue = coordinates[right]
        {
            answer = .boolean(
                leftValue <= rightValue
            )
        } else {
            return nil
        }
        return PrimeNativeNeuralGatePromptSolverResolution(
            answer: answer,
            codebook: codebook
        )
    }

    private func relationCoordinates(
        _ edges: [
            (
                from: Int,
                to: Int,
                delta: Int
            )
        ]
    ) -> [Int: Int]? {
        guard let first = edges.first
        else {
            return nil
        }
        var coordinates = [first.from: 0]
        var changed = true
        var passCount = 0
        while changed {
            let (
                nextPass,
                passOverflow
            ) = passCount.addingReportingOverflow(1)
            guard !passOverflow,
                  nextPass
                    <= Self.maximumRelationEdgeCount
                        + 1
            else {
                return nil
            }
            passCount = nextPass
            changed = false
            for edge in edges {
                if let from = coordinates[edge.from] {
                    let (
                        proposed,
                        overflow
                    ) = from
                        .addingReportingOverflow(
                            edge.delta
                        )
                    guard !overflow else {
                        return nil
                    }
                    if let current =
                        coordinates[edge.to],
                       current != proposed
                    {
                        return nil
                    }
                    if coordinates[edge.to] == nil {
                        coordinates[edge.to] =
                            proposed
                        changed = true
                    }
                }
                if let to = coordinates[edge.to] {
                    let (
                        proposed,
                        overflow
                    ) = to
                        .subtractingReportingOverflow(
                            edge.delta
                        )
                    guard !overflow else {
                        return nil
                    }
                    if let current =
                        coordinates[edge.from],
                       current != proposed
                    {
                        return nil
                    }
                    if coordinates[edge.from] == nil {
                        coordinates[edge.from] =
                            proposed
                        changed = true
                    }
                }
            }
        }
        let mentioned = Set(
            edges.flatMap {
                [$0.from, $0.to]
            }
        )
        guard mentioned.isSubset(
            of: Set(coordinates.keys)
        ) else {
            return nil
        }
        return coordinates
    }

    private func codebook(
        containing names: [String]
    ) -> PrimeNativeNeuralGatePromptSolverCodebook? {
        let requested = Set(names)
        let candidates = codebooks.filter {
            requested.isSubset(
                of: Set($0.entityNames)
            )
        }
        guard candidates.count == 1
        else {
            return nil
        }
        return candidates.first
    }

    private func slot(
        _ name: String,
        codebook:
            PrimeNativeNeuralGatePromptSolverCodebook
    ) -> Int? {
        codebook.entityNames.firstIndex(of: name)
    }

    private func action(
        _ line: String
    ) -> String? {
        guard let comma = line.range(of: ", ")
        else {
            return nil
        }
        let value = String(
            line[comma.upperBound...]
        )
        guard !value.contains(" many "),
              !value.contains("add to "),
              !value.contains("move from ")
        else {
            return nil
        }
        return value
    }

    private func questionLike(
        _ line: String
    ) -> Bool {
        [
            "What ",
            "Which ",
            "Is ",
            "Return ",
            "Report ",
            "Give ",
            "Determine ",
        ].contains {
            line.hasPrefix($0)
        }
    }

    private func captures(
        _ expression: NSRegularExpression,
        in text: String
    ) -> [String]? {
        let range = NSRange(
            text.startIndex ..< text.endIndex,
            in: text
        )
        guard let match = expression.firstMatch(
            in: text,
            options: [],
            range: range
        ),
              match.range == range
        else {
            return nil
        }
        var values: [String] = []
        let captureCount =
            match.numberOfRanges - 1
        values.reserveCapacity(captureCount)
        for index in 1 ..< match.numberOfRanges {
            let capturedRange =
                match.range(at: index)
            guard capturedRange.location
                    != NSNotFound,
                  let stringRange = Range(
                      capturedRange,
                      in: text
                  )
            else {
                return nil
            }
            values.append(
                String(text[stringRange])
            )
        }
        return values
    }

    private func firstCaptures(
        _ expressions: [NSRegularExpression],
        in text: String
    ) -> [String]? {
        for expression in expressions {
            if let values = captures(
                expression,
                in: text
            ) {
                return values
            }
        }
        return nil
    }

    private func checkedSum(
        _ values: [Int]
    ) -> Int? {
        var total = 0
        for value in values {
            let (
                next,
                overflow
            ) = total
                .addingReportingOverflow(value)
            guard !overflow else {
                return nil
            }
            total = next
        }
        return total
    }

    private func element<Element>(
        _ values: [Element],
        at index: Int
    ) -> Element? {
        guard values.indices.contains(index)
        else {
            return nil
        }
        return values[index]
    }

    private static func compile(
        _ patterns: [String]
    ) throws -> [NSRegularExpression] {
        var expressions:
            [NSRegularExpression] = []
        expressions.reserveCapacity(
            patterns.count
        )
        for pattern in patterns {
            expressions.append(
                try compile(pattern)
            )
        }
        return expressions
    }

    private static func compile(
        _ pattern: String
    ) throws -> NSRegularExpression {
        try NSRegularExpression(
            pattern: pattern,
            options: []
        )
    }
}

private enum PrimeNativeNeuralGatePromptSolverFamily {
    case scalar
    case transfer
    case ordering
    case relation
}

private struct PrimeNativeNeuralGatePromptSolverOpeningContract {
    let family:
        PrimeNativeNeuralGatePromptSolverFamily
    let allowedActionStyles:
        [PrimeNativeNeuralGatePromptSolverActionStyle]
}

private enum PrimeNativeNeuralGatePromptSolverActionStyle {
    case initial
    case start
    case opening
    case begin
    case record

    var firstLead: String {
        switch self {
        case .initial:
            "First"
        case .start:
            "Apply"
        case .opening:
            "In order"
        case .begin:
            "Execute"
        case .record:
            "Perform"
        }
    }

    var continuationLead: String {
        switch self {
        case .initial:
            "Then"
        case .start:
            "Continue"
        case .opening:
            "Next"
        case .begin:
            "Proceed"
        case .record:
            "Afterward"
        }
    }

    var surfaceIndex: Int {
        switch self {
        case .initial:
            0
        case .start:
            1
        case .opening:
            2
        case .begin:
            3
        case .record:
            4
        }
    }
}

private struct PrimeNativeNeuralGatePromptSolverCodebook {
    let entityNames: [String]
}

private struct PrimeNativeNeuralGatePromptSolverResolution {
    let answer:
        PrimeNativeNeuralGatePromptSolverAnswer
    let codebook:
        PrimeNativeNeuralGatePromptSolverCodebook
}

private enum PrimeNativeNeuralGatePromptSolverAnswer {
    case number(Int)
    case boolean(Bool)
    case entity(Int?)

    func display(
        using codebook:
            PrimeNativeNeuralGatePromptSolverCodebook
    ) -> String? {
        switch self {
        case .number(let value):
            return String(value)
        case .boolean(let value):
            return value ? "yes" : "no"
        case .entity(let slot):
            guard let slot else {
                return "none"
            }
            guard codebook.entityNames.indices
                .contains(slot)
            else {
                return nil
            }
            return codebook.entityNames[slot]
        }
    }
}

private enum PrimeNativeNeuralGatePromptSolverScalarOperation {
    case add(Int)
    case subtract(Int)
    case negate
}

private enum PrimeNativeNeuralGatePromptSolverTransferOperation {
    case move(
        amount: Int,
        source: Int,
        destination: Int
    )
}
