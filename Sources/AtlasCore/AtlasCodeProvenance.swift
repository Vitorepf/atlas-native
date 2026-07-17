import Foundation

/// What a commit did to one file. `additions`/`deletions` are absent for
/// binary files: Git measured nothing there, and nothing is not zero.
public struct AtlasCodeFileChange: Decodable, Equatable, Sendable, Identifiable {
    public let path: String
    public let status: AtlasCodeFileStatus
    public let additions: Int?
    public let deletions: Int?
    public let renamedFrom: String?

    public var id: String { path }

    /// The file name alone — what the eye reads first.
    public var fileName: String {
        String(path.split(separator: "/").last ?? Substring(path))
    }

    /// The directory that holds it, or nil at the repository root.
    public var directory: String? {
        let parts = path.split(separator: "/")
        guard parts.count > 1 else { return nil }
        return parts.dropLast().joined(separator: "/")
    }
}

/// The verb of a file change. Shape carries the meaning here — color is
/// reserved for STATE (main/violating/healed) and must not be spent on type.
public enum AtlasCodeFileStatus: String, Decodable, Equatable, Sendable {
    case added, modified, deleted, renamed, copied
    case typeChanged = "type_changed"
    /// A status Git grew after this build shipped: shown, never guessed.
    case unknown

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = AtlasCodeFileStatus(rawValue: raw) ?? .unknown
    }
}

/// Public C23 commit identity/provenance contract. Optional provenance fields
/// stay absent when the ledger has no matching record; the app must not turn
/// absence into a synthetic trace or quote.
public struct AtlasCodeProvenance: Decodable, Equatable, Sendable {
    public static let schemaVersion = "atlas.code.provenance.v2"

    public let schemaVersion: String
    public let repo: String
    public let hash: String
    public let commitMessage: String
    /// The commit body — the reasoning the author wrote down. Absent when the
    /// commit is a one-liner.
    public let commitBody: String?
    public let authorName: String
    public let authorEmail: String
    public let authoredAt: Int
    public let agent: String
    public let files: [AtlasCodeFileChange]
    public let traceId: String?
    public let operatorQuote: String?
    public let obra: [String]?
    public let gates: [String]?
    public let traceAgent: String?

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, repo, hash, commitMessage, commitBody, authorName, authorEmail
        case authoredAt, agent, files, traceId, operatorQuote, obra, gates, traceAgent
    }

    /// Who committed, in Portuguese. The server speaks slugs (`voce`,
    /// `autonomo:forge`); the surface speaks the operator's language. An
    /// unknown slug is shown as it came — never renamed into a guess.
    public var agentLabel: String {
        switch agent {
        case "voce": return "você"
        case "autonomo:desconhecido": return "autônomo não identificado"
        default:
            return agent.hasPrefix("autonomo:")
                ? "autônomo \(agent.dropFirst("autonomo:".count))"
                : agent
        }
    }

    /// "7 arquivos · +457 −323" — derived, never a second source of truth.
    /// Binary files count as files and add nothing to the line totals.
    public var diffHeadline: String? {
        guard !files.isEmpty else { return nil }
        let additions = files.compactMap(\.additions).reduce(0, +)
        let deletions = files.compactMap(\.deletions).reduce(0, +)
        let noun = files.count == 1 ? "arquivo" : "arquivos"
        return "\(files.count) \(noun) · +\(additions) \u{2212}\(deletions)"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Code provenance schema.")
        self.schemaVersion = schemaVersion
        self.repo = try values.decode(String.self, forKey: .repo)
        self.hash = try values.decode(String.self, forKey: .hash)
        self.commitMessage = try values.decode(String.self, forKey: .commitMessage)
        self.commitBody = try values.decodeIfPresent(String.self, forKey: .commitBody)
        self.authorName = try values.decode(String.self, forKey: .authorName)
        self.authorEmail = try values.decode(String.self, forKey: .authorEmail)
        self.authoredAt = try values.decode(Int.self, forKey: .authoredAt)
        self.agent = try values.decode(String.self, forKey: .agent)
        self.files = try values.decodeIfPresent([AtlasCodeFileChange].self, forKey: .files) ?? []
        self.traceId = try values.decodeIfPresent(String.self, forKey: .traceId)
        self.operatorQuote = try values.decodeIfPresent(String.self, forKey: .operatorQuote)
        self.obra = try values.decodeIfPresent([String].self, forKey: .obra)
        self.gates = try values.decodeIfPresent([String].self, forKey: .gates)
        self.traceAgent = try values.decodeIfPresent(String.self, forKey: .traceAgent)
    }
}
