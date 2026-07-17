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

    enum CodingKeys: String, CodingKey {
        case schemaVersion, repo, hash, commitMessage, commitBody, authorName, authorEmail
        case authoredAt, agent, files, traceId, operatorQuote, obra, gates, traceAgent
    }
}
