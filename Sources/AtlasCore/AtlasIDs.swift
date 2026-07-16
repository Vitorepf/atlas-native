import Foundation

/// IDs tipados do loop de conversa. Wire = String (single-value Codable);
/// o compilador impede trocar trace↔patch↔job em assinaturas públicas.

public struct TraceID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(_ rawValue: String) { self.rawValue = rawValue }
    public var description: String { rawValue }

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        rawValue = try c.decode(String.self)
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
    }
}

public struct ThreadID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(_ rawValue: String) { self.rawValue = rawValue }
    public var description: String { rawValue }

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        rawValue = try c.decode(String.self)
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
    }
}

public struct JobID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(_ rawValue: String) { self.rawValue = rawValue }
    public var description: String { rawValue }

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        rawValue = try c.decode(String.self)
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
    }
}

public struct PatchID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(_ rawValue: String) { self.rawValue = rawValue }
    public var description: String { rawValue }

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        rawValue = try c.decode(String.self)
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
    }
}

public struct ClientID: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(_ rawValue: String) { self.rawValue = rawValue }
    public var description: String { rawValue }

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        rawValue = try c.decode(String.self)
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
    }
}
