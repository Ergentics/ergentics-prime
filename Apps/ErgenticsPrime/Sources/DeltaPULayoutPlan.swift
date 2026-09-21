/// A closed, three-card presentation calculation. The source identifier is
/// copied from the caller's report; this code does not verify computation,
/// grant authority, inspect the host, or establish actual on-screen visibility.
enum DeltaPULayoutPlanner {
    static let cardCount = 3
    static let gap: Double = 12
    static let minimumCardWidth: Double = 200
    static let idealWidth: Double = 720
    static let maxExtent: Double = 1_048_576

    struct Proposal: Equatable, Sendable {
        let columns: Int
        let cardWidths: [Double]
        let viewportWidth: Double
        fileprivate let cardOrigins: [Double]

        // Only this file can manufacture a measurement proposal. Callers must
        // measure each of the three cards at its corresponding cardWidths entry.
        fileprivate init(columns: Int, cardWidths: [Double], viewportWidth: Double,
                         cardOrigins: [Double]) {
            self.columns = columns
            self.cardWidths = cardWidths
            self.viewportWidth = viewportWidth
            self.cardOrigins = cardOrigins
        }
    }

    struct Rect: Equatable, Sendable {
        let x: Double
        let y: Double
        let width: Double
        let height: Double

        fileprivate init(x: Double, y: Double, width: Double, height: Double) {
            self.x = x
            self.y = y
            self.width = width
            self.height = height
        }
    }

    struct Plan: Equatable, Sendable {
        let sourceStateID: String
        let width: Double
        let height: Double
        let columns: Int
        let cards: [Rect]
        let clipsToBounds = true

        fileprivate init(sourceStateID: String, width: Double, height: Double,
                         columns: Int, cards: [Rect]) {
            self.sourceStateID = sourceStateID
            self.width = width
            self.height = height
            self.columns = columns
            self.cards = cards
        }
    }

    /// Widths below the preferred minimum use one column at the actual width.
    /// No card is silently given a wider measurement proposal than its viewport.
    static func prepare(viewportWidth: Double) -> Proposal? {
        guard positiveExtent(viewportWidth) else { return nil }
        let columns = viewportWidth >= 3 * minimumCardWidth + 2 * gap ? 3
            : viewportWidth >= 2 * minimumCardWidth + gap ? 2 : 1
        let available = viewportWidth - Double(columns - 1) * gap
        let regularWidth = available / Double(columns)
        guard positiveExtent(available), positiveExtent(regularWidth) else { return nil }

        var origins: [Double] = []
        var widths: [Double] = []
        var left: Double = 0
        for column in 0..<columns {
            // Residual allocation is part of geometry generation, before card
            // measurement. Validation below still uses exact comparisons.
            let width = column == columns - 1 ? viewportWidth - left : regularWidth
            let right = left + width
            guard nonnegativeExtent(left), positiveExtent(width), positiveExtent(right),
                  right > left, right <= viewportWidth,
                  columns == 1 || width >= minimumCardWidth else { return nil }
            if column > 0 {
                let previousRight = origins[column - 1] + widths[column - 1]
                guard left > previousRight, left - previousRight >= gap else { return nil }
            }
            origins.append(left)
            widths.append(width)
            if column < columns - 1 {
                let next = nextOrigin(after: right)
                guard positiveExtent(next), next > right else { return nil }
                left = next
            }
        }
        guard origins[columns - 1] + widths[columns - 1] == viewportWidth else { return nil }
        return Proposal(columns: columns,
                        cardWidths: (0..<cardCount).map { widths[$0 % columns] },
                        viewportWidth: viewportWidth,
                        cardOrigins: (0..<cardCount).map { origins[$0 % columns] })
    }

    /// Heights must be measured at the exact widths returned by prepare().
    /// Individual heights are preserved; rows advance by their tallest card.
    /// Clipping belongs to the adapter, at this plan's full calculated bounds.
    static func generate(sourceStateID: String, proposal: Proposal, heights: [Double]) -> Plan? {
        guard heights.count == cardCount, heights.allSatisfy(positiveExtent),
              let expected = prepare(viewportWidth: proposal.viewportWidth), expected == proposal else { return nil }

        var cards: [Rect] = []
        var rowTop: Double = 0
        var rowBottom: Double = 0
        for index in 0..<cardCount {
            if index % proposal.columns == 0 {
                if index > 0 {
                    let next = nextOrigin(after: rowBottom)
                    guard positiveExtent(next), next > rowBottom, next - rowBottom >= gap else { return nil }
                    rowTop = next
                }
                let rowEnd = min(index + proposal.columns, cardCount)
                let rowHeight = heights[index..<rowEnd].max()!
                rowBottom = rowTop + rowHeight
                guard positiveExtent(rowBottom), rowBottom > rowTop else { return nil }
            }
            let card = Rect(x: proposal.cardOrigins[index], y: rowTop,
                            width: proposal.cardWidths[index], height: heights[index])
            let right = card.x + card.width
            let bottom = card.y + card.height
            guard nonnegativeExtent(card.x), nonnegativeExtent(card.y),
                  positiveExtent(right), positiveExtent(bottom), right > card.x, bottom > card.y,
                  right <= proposal.viewportWidth, bottom <= rowBottom else { return nil }
            cards.append(card)
        }

        // These are exact binary64 containment/non-overlap predicates, not
        // tolerance-based acceptance. No input is normalized to pass them.
        for index in 0..<cardCount {
            let card = cards[index]
            guard card.x + card.width <= proposal.viewportWidth,
                  card.y + card.height <= rowBottom else { return nil }
            for otherIndex in (index + 1)..<cardCount {
                let other = cards[otherIndex]
                guard card.x + card.width <= other.x || other.x + other.width <= card.x
                    || card.y + card.height <= other.y || other.y + other.height <= card.y else { return nil }
            }
        }
        return Plan(sourceStateID: sourceStateID, width: proposal.viewportWidth,
                    height: rowBottom, columns: proposal.columns, cards: cards)
    }

    /// Generate the first representable origin that retains the required gap.
    /// Crossing a binary64 binade can round ordinary addition toward the edge;
    /// one nextUp then supplies the minimal larger representable candidate.
    /// This generates new geometry; the exact gap/bounds checks are unchanged.
    private static func nextOrigin(after edge: Double) -> Double {
        let candidate = edge + gap
        return candidate - edge < gap ? candidate.nextUp : candidate
    }

    private static func positiveExtent(_ value: Double) -> Bool {
        value.isFinite && value > 0 && value <= maxExtent
    }

    private static func nonnegativeExtent(_ value: Double) -> Bool {
        value.isFinite && value >= 0 && value <= maxExtent
    }
}
