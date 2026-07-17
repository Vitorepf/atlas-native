import Foundation

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

enum JSONValueBridge {
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
