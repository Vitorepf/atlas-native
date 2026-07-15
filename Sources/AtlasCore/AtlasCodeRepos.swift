import Foundation

/// M3 radar contract. A frota por exceção: um repositório saudável chega só
/// com nome e `readable` — a ausência de `violations` É o silêncio, e a app
/// nunca a transforma em "0". Um repo ilegível, ou um scanner mudo, são
/// estados próprios: nenhum dos dois é saúde.
public struct AtlasCodeReposResponse: Decodable, Equatable, Sendable {
    public static let schemaVersion = "atlas.code.repos.v1"

    public let schemaVersion: String
    public let generatedAt: String
    public let repos: [AtlasCodeRepo]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, generatedAt, repos
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.decode(String.self, forKey: .schemaVersion)
        guard schemaVersion == Self.schemaVersion else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: values,
                debugDescription: "Unsupported Atlas Code repos schema."
            )
        }
        self.schemaVersion = schemaVersion
        self.generatedAt = try values.decode(String.self, forKey: .generatedAt)
        self.repos = try values.decode([AtlasCodeRepo].self, forKey: .repos)
    }
}

public struct AtlasCodeRepo: Decodable, Equatable, Sendable, Identifiable {
    public let slug: String
    public let name: String?
    public let readable: Bool
    public let unreadableReason: String?
    /// "unavailable" quando o scanner não respondeu. Ausente = respondeu.
    public let scan: String?
    /// Só existe quando há exceção real.
    public let violations: Int?
    public let rules: [String]?

    public var id: String { slug }

    /// O que a linha do radar diz. Silêncio é um estado legítimo — e o mais
    /// comum, porque saudável não grita.
    public enum Signal: Equatable, Sendable {
        case silent
        case exception(count: Int, rules: [String])
        case unreadable(reason: String)
        case scanUnavailable
    }

    public var signal: Signal {
        if !readable { return .unreadable(reason: unreadableReason ?? "repository_unreadable") }
        if scan == "unavailable" { return .scanUnavailable }
        if let violations, violations > 0 { return .exception(count: violations, rules: rules ?? []) }
        return .silent
    }
}
