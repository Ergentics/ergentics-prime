import XCTest

/// Pure geometry only: no view, host measurement, app launch, or authority.
final class DeltaPULayoutPlanTests: XCTestCase {
    private typealias Planner = DeltaPULayoutPlanner

    private func plan(width: Double, heights: [Double], source: String = "source-state") throws -> Planner.Plan {
        let proposal = try XCTUnwrap(Planner.prepare(viewportWidth: width))
        return try XCTUnwrap(Planner.generate(sourceStateID: source, proposal: proposal, heights: heights))
    }

    private func assertGeometry(_ plan: Planner.Plan, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(plan.cards.count, 3, file: file, line: line)
        XCTAssertTrue(plan.clipsToBounds, file: file, line: line)
        XCTAssertTrue(plan.width.isFinite && plan.width > 0 && plan.width <= Planner.maxExtent, file: file, line: line)
        XCTAssertTrue(plan.height.isFinite && plan.height > 0 && plan.height <= Planner.maxExtent, file: file, line: line)
        for (index, card) in plan.cards.enumerated() {
            for extent in [card.x, card.y, card.width, card.height] {
                XCTAssertTrue(extent.isFinite && extent >= 0 && extent <= Planner.maxExtent, file: file, line: line)
            }
            XCTAssertGreaterThan(card.width, 0, file: file, line: line)
            XCTAssertGreaterThan(card.height, 0, file: file, line: line)
            XCTAssertGreaterThan(card.x + card.width, card.x, file: file, line: line)
            XCTAssertGreaterThan(card.y + card.height, card.y, file: file, line: line)
            XCTAssertLessThanOrEqual(card.x + card.width, plan.width, file: file, line: line)
            XCTAssertLessThanOrEqual(card.y + card.height, plan.height, file: file, line: line)
            if index % plan.columns != 0 {
                let previous = plan.cards[index - 1]
                XCTAssertGreaterThanOrEqual(card.x - (previous.x + previous.width), Planner.gap,
                                            file: file, line: line)
            } else if index > 0 {
                let previousBottom = plan.cards[(index - plan.columns)..<index]
                    .map { $0.y + $0.height }.max()!
                XCTAssertGreaterThanOrEqual(card.y - previousBottom, Planner.gap, file: file, line: line)
            }
            for other in plan.cards.dropFirst(index + 1) {
                XCTAssertTrue(card.x + card.width <= other.x || other.x + other.width <= card.x
                    || card.y + card.height <= other.y || other.y + other.height <= card.y, file: file, line: line)
            }
        }
    }

    func testFrozenPolicyAndExactColumnBreakpoints() throws {
        XCTAssertEqual(Planner.cardCount, 3)
        XCTAssertEqual(Planner.gap, 12)
        XCTAssertEqual(Planner.minimumCardWidth, 200)
        XCTAssertEqual(Planner.idealWidth, 720)
        XCTAssertEqual(Planner.maxExtent, 1_048_576)
        let two: Double = 412
        let three: Double = 624
        for (width, expectedColumns) in [(two.nextDown, 1), (two, 2), (two.nextUp, 2),
                                         (three.nextDown, 2), (three, 3), (three.nextUp, 3)] {
            let proposal = try XCTUnwrap(Planner.prepare(viewportWidth: width))
            XCTAssertEqual(proposal.columns, expectedColumns)
            XCTAssertEqual(proposal.viewportWidth, width)
            XCTAssertEqual(proposal.cardWidths.count, 3)
            assertGeometry(try plan(width: width, heights: [20, 55, 35]))
        }
        let narrow = try XCTUnwrap(Planner.prepare(viewportWidth: 100))
        XCTAssertEqual(narrow.columns, 1)
        XCTAssertEqual(narrow.cardWidths, [100, 100, 100])
    }

    func testRejectsInvalidAndOutOfBoundViewportWidths() {
        let invalid: [Double] = [0, -0.0, -1, .nan, .infinity, -.infinity,
                                 Planner.maxExtent.nextUp, .greatestFiniteMagnitude]
        for width in invalid {
            XCTAssertNil(Planner.prepare(viewportWidth: width))
        }
        XCTAssertNotNil(Planner.prepare(viewportWidth: Planner.maxExtent))
    }

    func testRejectsWrongHeightCountsAndInvalidHeightsInEveryPosition() throws {
        let proposal = try XCTUnwrap(Planner.prepare(viewportWidth: Planner.idealWidth))
        let wrongCounts: [[Double]] = [[], [1], [1, 1], [1, 1, 1, 1]]
        for heights in wrongCounts {
            XCTAssertNil(Planner.generate(sourceStateID: "source", proposal: proposal, heights: heights))
        }
        let invalid: [Double] = [0, -0.0, -1, .nan, .infinity, -.infinity,
                                 Planner.maxExtent.nextUp, .greatestFiniteMagnitude]
        for index in 0..<3 {
            for value in invalid {
                var heights: [Double] = [10, 20, 30]
                heights[index] = value
                XCTAssertNil(Planner.generate(sourceStateID: "source", proposal: proposal, heights: heights))
            }
        }
    }

    func testUnequalHeightsArePreservedAndRowsUseTheirMaximum() throws {
        let heights: [Double] = [20, 55, 35]
        let three = try plan(width: 720, heights: heights)
        XCTAssertEqual(three.cards.map(\.x), [0, 244, 488])
        XCTAssertEqual(three.cards.map(\.y), [0, 0, 0])
        XCTAssertEqual(three.cards.map(\.width), [232, 232, 232])
        XCTAssertEqual(three.cards.map(\.height), heights)
        XCTAssertEqual(three.height, 55)

        let two = try plan(width: 412, heights: heights)
        XCTAssertEqual(two.cards.map(\.x), [0, 212, 0])
        XCTAssertEqual(two.cards.map(\.y), [0, 0, 67])
        XCTAssertEqual(two.cards.map(\.width), [200, 200, 200])
        XCTAssertEqual(two.cards.map(\.height), heights)
        XCTAssertEqual(two.height, 102)

        let one = try plan(width: 199, heights: heights)
        XCTAssertEqual(one.cards.map(\.x), [0, 0, 0])
        XCTAssertEqual(one.cards.map(\.y), [0, 32, 99])
        XCTAssertEqual(one.cards.map(\.width), [199, 199, 199])
        XCTAssertEqual(one.cards.map(\.height), heights)
        XCTAssertEqual(one.height, 134)
        for result in [three, two, one] { assertGeometry(result) }
    }

    func testResidualWidthIsExposedBeforeMeasurementAndNotChangedLater() throws {
        let width = Double(720).nextUp
        let proposal = try XCTUnwrap(Planner.prepare(viewportWidth: width))
        XCTAssertNotEqual(proposal.cardWidths[0], proposal.cardWidths[2])
        let result = try XCTUnwrap(Planner.generate(sourceStateID: "source", proposal: proposal,
                                                  heights: [20.25, 35.5, 50.75]))
        XCTAssertEqual(result.cards.map(\.width), proposal.cardWidths)
        XCTAssertEqual(result.cards[2].x + result.cards[2].width, width)
        assertGeometry(result)
    }

    func testHorizontalGapCrossingBinary64BoundaryUsesMinimalNextOrigin() throws {
        let width = Double(765).nextUp
        let proposal = try XCTUnwrap(Planner.prepare(viewportWidth: width))
        let result = try XCTUnwrap(Planner.generate(sourceStateID: "source", proposal: proposal,
                                                  heights: [20, 55, 35]))
        let firstRight = result.cards[0].x + result.cards[0].width
        let rounded = firstRight + Planner.gap
        XCTAssertLessThan(rounded - firstRight, Planner.gap)
        XCTAssertEqual(result.cards[1].x, rounded.nextUp)
        XCTAssertLessThan(result.cards[1].x.nextDown - firstRight, Planner.gap)
        XCTAssertGreaterThanOrEqual(result.cards[1].x - firstRight, Planner.gap)
        XCTAssertEqual(result.cards.map(\.width), proposal.cardWidths)
        XCTAssertEqual(result.cards[2].x + result.cards[2].width, width)
        assertGeometry(result)
    }

    func testFractionalRowHeightsRetainExactMinimumVerticalGap() throws {
        let tall = Double(247).nextUp
        for (width, heights, firstInNextRow) in [(200.0, [tall, 1.0, 2.0], 1),
                                                (412.0, [1.0, tall, 2.0], 2)] {
            let result = try plan(width: width, heights: heights)
            let rounded = tall + Planner.gap
            let next = result.cards[firstInNextRow].y
            XCTAssertLessThan(rounded - tall, Planner.gap)
            XCTAssertEqual(next, rounded.nextUp)
            XCTAssertLessThan(next.nextDown - tall, Planner.gap)
            XCTAssertGreaterThanOrEqual(next - tall, Planner.gap)
            XCTAssertEqual(result.cards.map(\.height), heights)
            assertGeometry(result)
        }
    }

    func testBoundedFractionalWidthSweepIsDeterministicAndExactlyContained() throws {
        let heights: [Double] = [Double(247).nextUp, 55.125, 35.75]
        // Exactly 3,072 finite widths around a frozen 1,024-point sample grid.
        for sample in 1...1_024 {
            let center = Double(sample) + Double(sample % 7) / 8
            for width in [center.nextDown, center, center.nextUp] {
                let result = try plan(width: width, heights: heights)
                XCTAssertEqual(result, try plan(width: width, heights: heights))
                assertGeometry(result)
            }
        }
    }

    func testVerticalExtentBoundAndUnrepresentableCardExtentAreRejected() throws {
        let narrow = try XCTUnwrap(Planner.prepare(viewportWidth: 100))
        XCTAssertNil(Planner.generate(sourceStateID: "source", proposal: narrow,
                                      heights: [Planner.maxExtent, 1, 1]))
        XCTAssertNil(Planner.generate(sourceStateID: "source", proposal: narrow,
                                      heights: [Planner.maxExtent - 26, 1, 2]))
        XCTAssertNil(Planner.generate(sourceStateID: "source", proposal: narrow,
                                      heights: [1, .leastNonzeroMagnitude, 1]))
        let edge = try plan(width: 100, heights: [Planner.maxExtent - 26, 1, 1])
        XCTAssertEqual(edge.height, Planner.maxExtent)
        assertGeometry(edge)
        let tallRow = try plan(width: 720, heights: [Planner.maxExtent, 1, 1])
        XCTAssertEqual(tallRow.height, Planner.maxExtent)
        assertGeometry(tallRow)
    }

    func testDeterministicExactGeometryAndOpaqueSourceIdentity() throws {
        let heights: [Double] = [17.25, 99.75, 50.125]
        let widths: [Double] = [1, 199, 200, Double(412).nextDown, 412, 500.25,
                                Double(624).nextDown, 624, 720, Planner.maxExtent]
        for width in widths {
            let first = try plan(width: width, heights: heights)
            let repeated = try plan(width: width, heights: heights)
            XCTAssertEqual(first, repeated)
            XCTAssertEqual(first.sourceStateID, "source-state")
            assertGeometry(first)
        }
        // Identity binding is a copy, not a digest check or admission decision.
        let empty = try plan(width: 720, heights: heights, source: "")
        let arbitrary = try plan(width: 720, heights: heights, source: "opaque—not a commitment")
        XCTAssertEqual(empty.sourceStateID, "")
        XCTAssertEqual(arbitrary.sourceStateID, "opaque—not a commitment")
        XCTAssertEqual(empty.cards, arbitrary.cards)
        XCTAssertEqual(empty.width, arbitrary.width)
        XCTAssertEqual(empty.height, arbitrary.height)
        XCTAssertNotEqual(empty, arbitrary)
    }
}
