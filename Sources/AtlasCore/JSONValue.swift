import Foundation

/// A `Codable` "any JSON value" — the Swift answer to the pervasive
/// `Record<string, unknown>` / `unknown` metadata bags in the TS DTOs
/// (plano-swift-puro §3.3, Codable gotcha #1). Type metadata like
/// `capture.metadata`, `trace.metadata`, routing payloads, etc. become
/// `[String: JSONValue]` instead of fighting the type system.
public enum JSONValue: Codable, Equatable, Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null; return }
        if let b = try? c.decode(Bool.self) { self = .bool(b); return }
        if let d = try? c.decode(Double.self) { self = .number(d); return }
        if let s = try? c.decode(String.self) { self = .string(s); return }
        if let a = try? c.decode([JSONValue].self) { self = .array(a); return }
        if let o = try? c.decode([String: JSONValue].self) { self = .object(o); return }
        throw DecodingError.dataCorruptedError(
            in: c, debugDescription: "Unrepresentable JSON value")
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .null: try c.encodeNil()
        case .bool(let b): try c.encode(b)
        case .number(let n): try c.encode(n)
        case .string(let s): try c.encode(s)
        case .array(let a): try c.encode(a)
        case .object(let o): try c.encode(o)
        }
    }

    // Ergonomic readers for the common access shapes.
    public var stringValue: String? { if case .string(let s) = self { return s } else { return nil } }
    public var doubleValue: Double? { if case .number(let n) = self { return n } else { return nil } }
    public var boolValue: Bool? { if case .bool(let b) = self { return b } else { return nil } }
    public subscript(_ key: String) -> JSONValue? {
        if case .object(let o) = self { return o[key] } else { return nil }
    }
}

/// Um bag `Record<string, unknown>` que TOLERA o quirk do Laravel: um associative
/// array vazio serializa como `[]` (array), não `{}`. Um `[String: JSONValue]`
/// puro quebra o decode nesse `[]` (typeMismatch). `JSONObject` decoda `{...}`
/// normalmente e trata `[]`/qualquer não-objeto como bag vazio — então todo campo
/// metadata/payload/signals/result_json da superfície sobrevive a payload real.
/// Acesso idêntico a um dict: `bag?["chave"]?.stringValue`, `.isEmpty`, `.count`.
public struct JSONObject: Codable, Equatable, Sendable {
    public var values: [String: JSONValue]
    public init(_ values: [String: JSONValue] = [:]) { self.values = values }

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let dict = try? c.decode([String: JSONValue].self) {
            values = dict
        } else {
            values = [:]   // `[]` (Laravel empty) ou qualquer não-objeto → vazio
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(values)
    }

    public subscript(_ key: String) -> JSONValue? { values[key] }
    public var isEmpty: Bool { values.isEmpty }
    public var count: Int { values.count }
}
