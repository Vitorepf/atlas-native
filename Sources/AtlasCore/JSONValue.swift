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
        if let o = try? c.decode([String: JSONValue].self) { self = .object(o); return }
        if let a = try? c.decode([JSONValue].self) { self = .array(a); return }
        if let b = try? c.decode(Bool.self) { self = .bool(b); return }
        if let d = try? c.decode(Double.self) { self = .number(d); return }
        if let s = try? c.decode(String.self) { self = .string(s); return }
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

private struct JSONValueCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(_ stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(stringValue: String) {
        self.init(stringValue)
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

private enum JSONValueBridge {
    static func decodeValue(from data: Data) throws -> JSONValue {
        try convert(parse(data), codingPath: [])
    }

    static func decodeObject(from data: Data) throws -> JSONObject {
        let parsed = try parse(data)
        guard let object = parsed as? [String: Any] else { return JSONObject() }
        return JSONObject(try convertObject(object, codingPath: []))
    }

    private static func parse(_ data: Data) throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
        } catch {
            let context = DecodingError.Context(
                codingPath: [],
                debugDescription: "The given data was not valid JSON.",
                underlyingError: error)
            throw DecodingError.dataCorrupted(context)
        }
    }

    private static func convert(_ object: Any, codingPath: [CodingKey]) throws -> JSONValue {
        switch object {
        case is NSNull:
            return .null
        case let string as String:
            return .string(string)
        case let number as NSNumber:
            if CFGetTypeID(number) == CFBooleanGetTypeID() { return .bool(number.boolValue) }
            return .number(number.doubleValue)
        case let array as [Any]:
            return .array(try array.enumerated().map { index, element in
                try convert(element, codingPath: codingPath + [JSONValueCodingKey(intValue: index)!])
            })
        case let object as [String: Any]:
            return .object(try convertObject(object, codingPath: codingPath))
        default:
            let context = DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Unrepresentable JSON value")
            throw DecodingError.dataCorrupted(context)
        }
    }

    private static func convertObject(_ object: [String: Any], codingPath: [CodingKey]) throws -> [String: JSONValue] {
        var values: [String: JSONValue] = [:]
        values.reserveCapacity(object.count)
        for (key, value) in object {
            let childKey = JSONValueCodingKey(key)
            values[key] = try convert(value, codingPath: codingPath + [childKey])
        }
        return values
    }
}

public extension JSONDecoder {
    func decode(_ type: JSONValue.Type, from data: Data) throws -> JSONValue {
        try JSONValueBridge.decodeValue(from: data)
    }

    func decode(_ type: JSONObject.Type, from data: Data) throws -> JSONObject {
        try JSONValueBridge.decodeObject(from: data)
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
