import Foundation

/// A dependency-free unsigned integer that keeps metric transforms exact on
/// the package's macOS 14 deployment floor. Limbs are base 2^32.
struct DisposalWideUInt: Equatable, Comparable, Sendable, CustomStringConvertible {
    private var limbs: [UInt32]

    init(_ value: UInt64 = 0) {
        let low = UInt32(truncatingIfNeeded: value)
        let high = UInt32(truncatingIfNeeded: value >> 32)
        limbs = high == 0 ? (low == 0 ? [] : [low]) : [low, high]
    }

    private init(normalized limbs: [UInt32]) {
        var value = limbs
        while value.last == 0 { value.removeLast() }
        self.limbs = value
    }

    var isZero: Bool { limbs.isEmpty }
    var isOdd: Bool { limbs.first.map { $0 & 1 == 1 } ?? false }

    static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.limbs.count != rhs.limbs.count {
            return lhs.limbs.count < rhs.limbs.count
        }
        for index in lhs.limbs.indices.reversed() where lhs.limbs[index] != rhs.limbs[index] {
            return lhs.limbs[index] < rhs.limbs[index]
        }
        return false
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        let count = max(lhs.limbs.count, rhs.limbs.count)
        var result = [UInt32](repeating: 0, count: count)
        var carry: UInt64 = 0
        for index in 0..<count {
            let left = index < lhs.limbs.count ? UInt64(lhs.limbs[index]) : 0
            let right = index < rhs.limbs.count ? UInt64(rhs.limbs[index]) : 0
            let sum = left + right + carry
            result[index] = UInt32(truncatingIfNeeded: sum)
            carry = sum >> 32
        }
        if carry != 0 { result.append(UInt32(carry)) }
        return Self(normalized: result)
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        precondition(lhs >= rhs)
        var result = lhs.limbs
        var borrow: UInt64 = 0
        for index in result.indices {
            let left = UInt64(result[index])
            let right = (index < rhs.limbs.count ? UInt64(rhs.limbs[index]) : 0) + borrow
            if left >= right {
                result[index] = UInt32(left - right)
                borrow = 0
            } else {
                result[index] = UInt32((UInt64(1) << 32) + left - right)
                borrow = 1
            }
        }
        precondition(borrow == 0)
        return Self(normalized: result)
    }

    static func * (lhs: Self, rhs: Self) -> Self {
        guard !lhs.isZero, !rhs.isZero else { return Self() }
        var result = [UInt32](repeating: 0, count: lhs.limbs.count + rhs.limbs.count)
        for leftIndex in lhs.limbs.indices {
            var carry: UInt64 = 0
            for rightIndex in rhs.limbs.indices {
                let resultIndex = leftIndex + rightIndex
                let product = UInt64(lhs.limbs[leftIndex]) * UInt64(rhs.limbs[rightIndex])
                // The maximum here is exactly UInt64.max:
                // (2^32-1)^2 + (2^32-1) + (2^32-1).
                let total = product + UInt64(result[resultIndex]) + carry
                result[resultIndex] = UInt32(truncatingIfNeeded: total)
                carry = total >> 32
            }
            var resultIndex = leftIndex + rhs.limbs.count
            while carry != 0 {
                let total = UInt64(result[resultIndex]) + carry
                result[resultIndex] = UInt32(truncatingIfNeeded: total)
                carry = total >> 32
                resultIndex += 1
                if carry != 0 && resultIndex == result.count { result.append(0) }
            }
        }
        return Self(normalized: result)
    }

    static func / (lhs: Self, rhs: Self) -> Self {
        lhs.quotientAndRemainder(dividingBy: rhs).0
    }

    static func % (lhs: Self, rhs: Self) -> Self {
        lhs.quotientAndRemainder(dividingBy: rhs).1
    }

    private var bitWidth: Int {
        guard let high = limbs.last else { return 0 }
        return (limbs.count - 1) * 32 + (32 - high.leadingZeroBitCount)
    }

    private func bit(at index: Int) -> Bool {
        let limb = index / 32
        guard limb < limbs.count else { return false }
        return limbs[limb] & (UInt32(1) << UInt32(index % 32)) != 0
    }

    private mutating func shiftLeftOne(adding bit: Bool) {
        var carry: UInt64 = bit ? 1 : 0
        for index in limbs.indices {
            let value = (UInt64(limbs[index]) << 1) | carry
            limbs[index] = UInt32(truncatingIfNeeded: value)
            carry = value >> 32
        }
        if carry != 0 { limbs.append(UInt32(carry)) }
        if limbs.isEmpty && bit { limbs = [1] }
    }

    private mutating func setBit(_ index: Int) {
        let limb = index / 32
        if limbs.count <= limb {
            limbs.append(contentsOf: repeatElement(0, count: limb + 1 - limbs.count))
        }
        limbs[limb] |= UInt32(1) << UInt32(index % 32)
    }

    private func quotientAndRemainder(dividingBy divisor: Self) -> (Self, Self) {
        precondition(!divisor.isZero)
        guard self >= divisor else { return (Self(), self) }
        var quotient = Self()
        var remainder = Self()
        for index in stride(from: bitWidth - 1, through: 0, by: -1) {
            remainder.shiftLeftOne(adding: bit(at: index))
            if remainder >= divisor {
                remainder = remainder - divisor
                quotient.setBit(index)
            }
        }
        return (quotient, remainder)
    }

    private func quotientAndRemainder(dividingBy divisor: UInt32) -> (Self, UInt32) {
        precondition(divisor != 0)
        var quotient = [UInt32](repeating: 0, count: limbs.count)
        var remainder: UInt64 = 0
        for index in limbs.indices.reversed() {
            let value = (remainder << 32) | UInt64(limbs[index])
            quotient[index] = UInt32(value / UInt64(divisor))
            remainder = value % UInt64(divisor)
        }
        return (Self(normalized: quotient), UInt32(remainder))
    }

    var description: String {
        guard !isZero else { return "0" }
        var value = self
        var groups: [UInt32] = []
        while !value.isZero {
            let division = value.quotientAndRemainder(dividingBy: 1_000_000_000)
            value = division.0
            groups.append(division.1)
        }
        var output = String(groups.removeLast())
        for group in groups.reversed() {
            let digits = String(group)
            output += String(repeating: "0", count: 9 - digits.count) + digits
        }
        return output
    }
}

struct DisposalRational: Equatable, Sendable {
    let numerator: DisposalWideUInt
    let denominator: DisposalWideUInt
    let unit: String

    init(_ numerator: DisposalWideUInt, _ denominator: DisposalWideUInt, unit: String) throws {
        try disposalRequire(!denominator.isZero, "RATIONAL_ZERO_DENOMINATOR")
        if numerator.isZero {
            self.numerator = DisposalWideUInt()
            self.denominator = DisposalWideUInt(1)
        } else {
            let divisor = disposalGCD(numerator, denominator)
            self.numerator = numerator / divisor
            self.denominator = denominator / divisor
        }
        self.unit = unit
    }

    func approximation(places: Int = 12) throws -> String {
        try disposalRequire((0...18).contains(places), "RATIONAL_DECIMAL_PLACES")
        var scale = DisposalWideUInt(1)
        for _ in 0..<places { scale = try disposalMultiply(scale, DisposalWideUInt(10)) }
        let scaled = try disposalMultiply(numerator, scale)
        var quotient = scaled / denominator
        let remainder = scaled % denominator
        let complement = denominator - remainder
        if remainder > complement || (remainder == complement && quotient.isOdd) {
            quotient = quotient + DisposalWideUInt(1)
        }
        if places == 0 { return quotient.description }
        let whole = quotient / scale
        var fraction = (quotient % scale).description
        if fraction.count < places {
            fraction = String(repeating: "0", count: places - fraction.count) + fraction
        }
        return whole.description + "." + fraction
    }
}

@inline(__always)
func disposalDelta(_ later: UInt64, _ earlier: UInt64) throws -> UInt64 {
    let result = later.subtractingReportingOverflow(earlier)
    try disposalRequire(!result.overflow, "COUNTER_REGRESSION")
    return result.partialValue
}

@inline(__always)
func disposalSum(_ lhs: UInt64, _ rhs: UInt64) throws -> UInt64 {
    let result = lhs.addingReportingOverflow(rhs)
    try disposalRequire(!result.overflow, "COUNTER_SUM_OVERFLOW")
    return result.partialValue
}

@inline(__always)
func disposalMultiply(
    _ lhs: DisposalWideUInt,
    _ rhs: DisposalWideUInt
) throws -> DisposalWideUInt {
    lhs * rhs
}

func disposalGCD(_ lhs: DisposalWideUInt, _ rhs: DisposalWideUInt) -> DisposalWideUInt {
    var a = lhs
    var b = rhs
    while !b.isZero {
        let remainder = a % b
        a = b
        b = remainder
    }
    return a
}

func disposalCPUTime(
    ticks: UInt64,
    timebaseNumerator: UInt64,
    timebaseDenominator: UInt64
) throws -> DisposalRational {
    let numerator = try disposalMultiply(
        DisposalWideUInt(ticks), DisposalWideUInt(timebaseNumerator))
    return try DisposalRational(
        numerator,
        DisposalWideUInt(timebaseDenominator),
        unit: "nanoseconds")
}

func disposalCPUPercent(
    ticks: UInt64,
    elapsedNanoseconds: UInt64,
    timebaseNumerator: UInt64,
    timebaseDenominator: UInt64
) throws -> DisposalRational {
    try disposalRequire(elapsedNanoseconds > 0, "CPU_ELAPSED_ZERO")
    var numerator = try disposalMultiply(
        DisposalWideUInt(ticks), DisposalWideUInt(timebaseNumerator))
    numerator = try disposalMultiply(numerator, DisposalWideUInt(100))
    let denominator = try disposalMultiply(
        DisposalWideUInt(elapsedNanoseconds),
        DisposalWideUInt(timebaseDenominator))
    return try DisposalRational(
        numerator,
        denominator,
        unit: "aggregate_core_equivalent_percent")
}

func disposalEnergyJoules(_ nanojoules: UInt64) throws -> DisposalRational {
    try DisposalRational(
        DisposalWideUInt(nanojoules),
        DisposalWideUInt(1_000_000_000),
        unit: "joules")
}

func disposalEnergyErgs(_ nanojoules: UInt64) throws -> DisposalRational {
    try DisposalRational(
        DisposalWideUInt(nanojoules),
        DisposalWideUInt(100),
        unit: "ergs")
}

func disposalPower(
    nanojoules: UInt64,
    elapsedNanoseconds: UInt64
) throws -> DisposalRational {
    try disposalRequire(elapsedNanoseconds > 0, "POWER_ELAPSED_ZERO")
    return try DisposalRational(
        DisposalWideUInt(nanojoules),
        DisposalWideUInt(elapsedNanoseconds),
        unit: "watts")
}
