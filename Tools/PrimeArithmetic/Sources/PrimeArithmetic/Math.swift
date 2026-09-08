//
//  Math.swift  (AlgebraKit)
//
//  A tiny exact-rational type + a linear-expression parser/evaluator. These power
//  the answer-equivalence checker (SEED §3a) and clean answer formatting. The
//  expression layer supports + - * / parentheses, a single variable `x`, integers,
//  decimals, fractions, unary minus, and implicit multiplication (`2x`, `2(x+3)`,
//  `(x+1)(2)`). Pure value types — fully testable headlessly.
//

import Foundation

/// Exact reduced rational (den > 0). Used for clean answers / distractors.
public struct Rational: Hashable, Sendable, CustomStringConvertible {
    public let num: Int
    public let den: Int

    public init(_ n: Int, _ d: Int = 1) {
        precondition(d != 0, "Rational denominator must be non-zero")
        var nn = n, dd = d
        if dd < 0 { nn = -nn; dd = -dd }
        let g = Rational.gcd(abs(nn), dd)
        self.num = g == 0 ? 0 : nn / g
        self.den = g == 0 ? 1 : dd / g
    }

    static func gcd(_ a: Int, _ b: Int) -> Int { b == 0 ? a : gcd(b, a % b) }

    public var doubleValue: Double { Double(num) / Double(den) }
    public var isInteger: Bool { den == 1 }

    public static func + (l: Rational, r: Rational) -> Rational { Rational(l.num*r.den + r.num*l.den, l.den*r.den) }
    public static func - (l: Rational, r: Rational) -> Rational { Rational(l.num*r.den - r.num*l.den, l.den*r.den) }
    public static func * (l: Rational, r: Rational) -> Rational { Rational(l.num*r.num, l.den*r.den) }
    public static func / (l: Rational, r: Rational) -> Rational { Rational(l.num*r.den, l.den*r.num) }
    public static prefix func - (r: Rational) -> Rational { Rational(-r.num, r.den) }

    /// "5", "-3/2".
    public var description: String { den == 1 ? "\(num)" : "\(num)/\(den)" }
}

// ── Linear-expression AST + parser/evaluator ──────────────────────────────

public indirect enum Expr: Sendable {
    case num(Double)
    case x
    case y
    case neg(Expr)
    case add(Expr, Expr)
    case sub(Expr, Expr)
    case mul(Expr, Expr)
    case pow(Expr, Expr)
    case div(Expr, Expr)
    case sqrtOf(Expr)
    case nthRootOf(Int, Expr)   // ⁿ√x — index ≥ 2; index 2 routes through .sqrtOf as a convention
    case ln(Expr)        // natural log
    case log10(Expr)     // common (base-10) log
    case cosOf(Expr)     // cosine
    case sinOf(Expr)     // sine
    case tanOf(Expr)     // tangent (nil at the poles)

    /// Evaluate at given x (and y, default 0 for single-variable expressions). Returns
    /// nil only on division whose denominator evaluates to ~0 (caller skips that sample).
    public func eval(x xv: Double, y yv: Double = 0) -> Double? {
        switch self {
        case .num(let n): return n
        case .x: return xv
        case .y: return yv
        case .neg(let a): return a.eval(x: xv, y: yv).map { -$0 }
        case .add(let a, let b):
            guard let l = a.eval(x: xv, y: yv), let r = b.eval(x: xv, y: yv) else { return nil }
            return l + r
        case .sub(let a, let b):
            guard let l = a.eval(x: xv, y: yv), let r = b.eval(x: xv, y: yv) else { return nil }
            return l - r
        case .mul(let a, let b):
            guard let l = a.eval(x: xv, y: yv), let r = b.eval(x: xv, y: yv) else { return nil }
            return l * r
        case .pow(let a, let b):
            guard let l = a.eval(x: xv, y: yv), let r = b.eval(x: xv, y: yv) else { return nil }
            return Foundation.pow(l, r)
        case .sqrtOf(let a):
            guard let v = a.eval(x: xv, y: yv), v >= 0 else { return nil }
            return v.squareRoot()
        case .nthRootOf(let n, let a):
            // n ≥ 2. Even index of negative → undefined (skip sample). Odd index of
            // negative → real-valued: -(|v|^(1/n)).
            guard n >= 2 else { return nil }
            guard let v = a.eval(x: xv, y: yv) else { return nil }
            if v == 0 { return 0 }
            if v < 0 {
                if n % 2 == 0 { return nil }
                return -Foundation.pow(-v, 1.0 / Double(n))
            }
            return Foundation.pow(v, 1.0 / Double(n))
        case .ln(let a):
            guard let v = a.eval(x: xv, y: yv), v > 1e-12 else { return nil }   // log undefined for ≤ 0 → skip sample
            return Foundation.log(v)
        case .log10(let a):
            guard let v = a.eval(x: xv, y: yv), v > 1e-12 else { return nil }
            return Foundation.log10(v)
        case .cosOf(let a):
            guard let v = a.eval(x: xv, y: yv) else { return nil }
            return Foundation.cos(v)
        case .sinOf(let a):
            guard let v = a.eval(x: xv, y: yv) else { return nil }
            return Foundation.sin(v)
        case .tanOf(let a):
            guard let v = a.eval(x: xv, y: yv) else { return nil }
            // Undefined at π/2 + kπ — guard via cos near zero.
            if abs(Foundation.cos(v)) < 1e-12 { return nil }
            return Foundation.tan(v)
        case .div(let a, let b):
            guard let l = a.eval(x: xv, y: yv), let r = b.eval(x: xv, y: yv), abs(r) > 1e-12 else { return nil }
            return l / r
        }
    }

    /// Single-variable convenience (y = 0). Back-compat for the value/expression/relation paths.
    public func eval(at v: Double) -> Double? { eval(x: v, y: 0) }

    /// COMPLEX evaluation: walk the AST treating `sqrt(-1)` as the imaginary unit i. Returns
    /// (real, imag) for any expression in cos/sin/tan/π/e/i and the usual arithmetic, or nil on
    /// undefined operations (real-domain log of ≤ 0, tan at poles, division by zero, complex sqrt).
    /// Lets `√2(cos(π/4) + i sin(π/4))` compare numerically to `1 + i` (Equivalence routes through this).
    public func evalComplex() -> (real: Double, imag: Double)? {
        switch self {
        case .num(let n): return (n, 0)
        case .x, .y: return (0, 0)
        case .neg(let a):
            guard let (r, i) = a.evalComplex() else { return nil }
            return (-r, -i)
        case .add(let a, let b):
            guard let (ar, ai) = a.evalComplex(), let (br, bi) = b.evalComplex() else { return nil }
            return (ar + br, ai + bi)
        case .sub(let a, let b):
            guard let (ar, ai) = a.evalComplex(), let (br, bi) = b.evalComplex() else { return nil }
            return (ar - br, ai - bi)
        case .mul(let a, let b):
            guard let (ar, ai) = a.evalComplex(), let (br, bi) = b.evalComplex() else { return nil }
            return (ar * br - ai * bi, ar * bi + ai * br)
        case .div(let a, let b):
            guard let (ar, ai) = a.evalComplex(), let (br, bi) = b.evalComplex() else { return nil }
            let denom = br * br + bi * bi
            guard denom > 1e-18 else { return nil }
            return ((ar * br + ai * bi) / denom, (ai * br - ar * bi) / denom)
        case .pow(let a, let b):
            // Only support REAL exponents — complex exponentiation isn't needed for the curriculum.
            guard let (ar, ai) = a.evalComplex(), let (br, bi) = b.evalComplex(), abs(bi) < 1e-12 else { return nil }
            let r = (ar * ar + ai * ai).squareRoot()
            let theta = Foundation.atan2(ai, ar)
            let rn = Foundation.pow(r, br)
            let nTheta = br * theta
            return (rn * Foundation.cos(nTheta), rn * Foundation.sin(nTheta))
        case .sqrtOf(let a):
            // SPECIAL: sqrt(-1) IS i. Other negative real sqrt → use polar (positive imag branch).
            if case .num(let v) = a, abs(v + 1) < 1e-12 { return (0, 1) }
            guard let (ar, ai) = a.evalComplex() else { return nil }
            if abs(ai) < 1e-12 {
                if ar >= 0 { return (ar.squareRoot(), 0) }
                return (0, (-ar).squareRoot())   // principal branch
            }
            // Complex sqrt: principal branch via polar.
            let r = (ar * ar + ai * ai).squareRoot().squareRoot()
            let theta = Foundation.atan2(ai, ar) / 2
            return (r * Foundation.cos(theta), r * Foundation.sin(theta))
        case .nthRootOf(let n, let a):
            // Real-valued nth root only (per curriculum scope); complex nth roots are
            // out of L6b scope. Reject any imaginary input.
            guard n >= 2 else { return nil }
            guard let (ar, ai) = a.evalComplex(), abs(ai) < 1e-12 else { return nil }
            if abs(ar) < 1e-12 { return (0, 0) }
            if ar < 0 {
                if n % 2 == 0 { return nil }
                return (-Foundation.pow(-ar, 1.0 / Double(n)), 0)
            }
            return (Foundation.pow(ar, 1.0 / Double(n)), 0)
        case .ln(let a):
            guard let (ar, ai) = a.evalComplex(), abs(ai) < 1e-12, ar > 1e-12 else { return nil }
            return (Foundation.log(ar), 0)
        case .log10(let a):
            guard let (ar, ai) = a.evalComplex(), abs(ai) < 1e-12, ar > 1e-12 else { return nil }
            return (Foundation.log10(ar), 0)
        case .cosOf(let a):
            guard let (ar, ai) = a.evalComplex(), abs(ai) < 1e-12 else { return nil }
            return (Foundation.cos(ar), 0)
        case .sinOf(let a):
            guard let (ar, ai) = a.evalComplex(), abs(ai) < 1e-12 else { return nil }
            return (Foundation.sin(ar), 0)
        case .tanOf(let a):
            guard let (ar, ai) = a.evalComplex(), abs(ai) < 1e-12 else { return nil }
            if abs(Foundation.cos(ar)) < 1e-12 { return nil }
            return (Foundation.tan(ar), 0)
        }
    }
}

public enum ExprError: Error, Equatable { case empty, unexpected(String), trailing(String) }

/// Recursive-descent parser. `Expr.parse("2(x+3)")`.
public enum ExprParser {
    private enum Tok: Equatable { case num(Double), x, y, plus, minus, star, slash, caret, sqrt, cbrt, fourthroot, nthroot, ln, log, cos, sin, tan, lparen, rparen, comma }

    public static func parse(_ s: String) throws -> Expr {
        let toks = try tokenize(s)
        guard !toks.isEmpty else { throw ExprError.empty }
        var i = 0
        let e = try parseAdditive(toks, &i)
        guard i == toks.count else { throw ExprError.trailing("at token \(i)") }
        return e
    }

    private static func tokenize(_ s: String) throws -> [Tok] {
        var toks: [Tok] = []
        // Normalize: sqrt → √, unicode minus (U+2212) → ASCII '-' (so curriculum stems with "−π/4"
        // parse identically to "-π/4").
        let chars = Array(s
            .replacingOccurrences(of: "sqrt", with: "√", options: .caseInsensitive)
            .replacingOccurrences(of: "−", with: "-")
            // L6b — radical canonical-form symbols emitted by RadicalForm.description.
            // Round-trip: parse can ingest what the engine printed.
            .replacingOccurrences(of: "∛", with: "cbrt")
            .replacingOccurrences(of: "∜", with: "fourthroot"))
        var i = 0
        while i < chars.count {
            let c = chars[i]
            if c == " " || c == "\t" { i += 1; continue }
            switch c {
            case "+": toks.append(.plus); i += 1
            case "-": toks.append(.minus); i += 1
            case "*": toks.append(.star); i += 1
            case "/": toks.append(.slash); i += 1
            case "√": toks.append(.sqrt); i += 1
            case "^": toks.append(.caret); i += 1
            case "²": toks.append(.caret); toks.append(.num(2)); i += 1
            case "³": toks.append(.caret); toks.append(.num(3)); i += 1
            case "(", "[": toks.append(.lparen); i += 1
            case ")", "]": toks.append(.rparen); i += 1
            case ",": toks.append(.comma); i += 1
            case "x", "X": toks.append(.x); i += 1
            case "y", "Y": toks.append(.y); i += 1
            default:
                if c.isNumber || c == "." {
                    var j = i
                    while j < chars.count && (chars[j].isNumber || chars[j] == ".") { j += 1 }
                    guard let v = Double(String(chars[i..<j])) else { throw ExprError.unexpected(String(chars[i..<j])) }
                    toks.append(.num(v)); i = j
                } else if c.isLetter || c == "π" {
                    // Functions (sqrt/cos/sin/tan/log/ln/exp) + constants (e for Euler, π for pi) +
                    // imaginary unit `i` (parsed as sqrt(-1); real-valued eval returns nil, routing
                    // complex through Equivalence.evalComplex). Match longest keyword first.
                    if      chars[i...].starts(with: "cbrt")       { toks.append(.cbrt); i += 4 }
                    else if chars[i...].starts(with: "fourthroot") { toks.append(.fourthroot); i += 10 }
                    else if chars[i...].starts(with: "nthroot")    { toks.append(.nthroot); i += 7 }
                    else if chars[i...].starts(with: "cos") { toks.append(.cos); i += 3 }
                    else if chars[i...].starts(with: "sin") { toks.append(.sin); i += 3 }
                    else if chars[i...].starts(with: "tan") { toks.append(.tan); i += 3 }
                    else if chars[i...].starts(with: "log") { toks.append(.log); i += 3 }
                    else if chars[i...].starts(with: "ln")  { toks.append(.ln);  i += 2 }
                    else if c == "π"                        { toks.append(.num(Double.pi)); i += 1 }
                    else if chars[i...].starts(with: "pi")  { toks.append(.num(Double.pi)); i += 2 }
                    else if c == "e" || c == "E" { toks.append(.num(M_E)); i += 1 }
                    else if c == "i" || c == "I" { toks.append(.sqrt); toks.append(.lparen); toks.append(.num(-1)); toks.append(.rparen); i += 1 }
                    else { throw ExprError.unexpected(String(c)) }
                } else {
                    throw ExprError.unexpected(String(c))
                }
            }
        }
        return toks
    }

    // additive := multiplicative (('+'|'-') multiplicative)*
    private static func parseAdditive(_ t: [Tok], _ i: inout Int) throws -> Expr {
        var left = try parseMultiplicative(t, &i)
        while i < t.count, t[i] == .plus || t[i] == .minus {
            let op = t[i]; i += 1
            let right = try parseMultiplicative(t, &i)
            left = op == .plus ? .add(left, right) : .sub(left, right)
        }
        return left
    }

    // multiplicative := unary (('*'|'/'| implicit) unary)*
    private static func parseMultiplicative(_ t: [Tok], _ i: inout Int) throws -> Expr {
        var left = try parseUnary(t, &i)
        while i < t.count {
            if t[i] == .star || t[i] == .slash {
                let op = t[i]; i += 1
                let right = try parseUnary(t, &i)
                left = op == .star ? .mul(left, right) : .div(left, right)
            } else if startsFactor(t[i]) {
                // implicit multiplication: 2x, 2(x+1), (x+1)(2), x(2)
                let right = try parseUnary(t, &i)
                left = .mul(left, right)
            } else {
                break
            }
        }
        return left
    }

    private static func startsFactor(_ tok: Tok) -> Bool {
        switch tok { case .num, .x, .y, .sqrt, .cbrt, .fourthroot, .nthroot, .ln, .log, .cos, .sin, .tan, .lparen: return true; default: return false }
    }

    // unary := '-' unary | '+' unary | power
    private static func parseUnary(_ t: [Tok], _ i: inout Int) throws -> Expr {
        guard i < t.count else { throw ExprError.unexpected("end") }
        if t[i] == .minus { i += 1; return .neg(try parseUnary(t, &i)) }
        if t[i] == .plus { i += 1; return try parseUnary(t, &i) }
        return try parsePower(t, &i)
    }

    // power := primary ('^' unary)?   (right-associative; binds tighter than unary minus)
    private static func parsePower(_ t: [Tok], _ i: inout Int) throws -> Expr {
        let base = try parsePrimary(t, &i)
        if i < t.count, t[i] == .caret {
            i += 1
            let exp = try parseUnary(t, &i)
            return .pow(base, exp)
        }
        return base
    }

    private static func parsePrimary(_ t: [Tok], _ i: inout Int) throws -> Expr {
        guard i < t.count else { throw ExprError.unexpected("end") }
        switch t[i] {
        case .num(let v): i += 1; return .num(v)
        case .x: i += 1; return .x
        case .y: i += 1; return .y
        case .sqrt: i += 1; return .sqrtOf(try parsePrimary(t, &i))
        case .cbrt: i += 1; return .nthRootOf(3, try parsePrimary(t, &i))
        case .fourthroot: i += 1; return .nthRootOf(4, try parsePrimary(t, &i))
        case .nthroot:
            // nthroot(N, x) — N is a non-negative integer literal; x is any expression.
            i += 1
            guard i < t.count, t[i] == .lparen else { throw ExprError.unexpected("expected ( after nthroot") }
            i += 1
            guard i < t.count, case .num(let nv) = t[i], nv == nv.rounded(), nv >= 2 else {
                throw ExprError.unexpected("nthroot index must be an integer ≥ 2")
            }
            i += 1
            guard i < t.count, t[i] == .comma else { throw ExprError.unexpected("expected , in nthroot(n, x)") }
            i += 1
            let inner = try parseAdditive(t, &i)
            guard i < t.count, t[i] == .rparen else { throw ExprError.unexpected("expected ) closing nthroot") }
            i += 1
            return .nthRootOf(Int(nv), inner)
        case .ln: i += 1; return .ln(try parsePrimary(t, &i))
        case .log: i += 1; return .log10(try parsePrimary(t, &i))
        case .cos: i += 1; return .cosOf(try parsePrimary(t, &i))
        case .sin: i += 1; return .sinOf(try parsePrimary(t, &i))
        case .tan: i += 1; return .tanOf(try parsePrimary(t, &i))
        case .lparen:
            i += 1
            let e = try parseAdditive(t, &i)
            guard i < t.count, t[i] == .rparen else { throw ExprError.unexpected("expected )") }
            i += 1
            return e
        default:
            throw ExprError.unexpected("token \(i)")
        }
    }
}
