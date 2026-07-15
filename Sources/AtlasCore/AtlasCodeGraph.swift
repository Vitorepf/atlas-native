import Foundation

/// Public C22 topology contract. The app receives Git facts only; it does not
/// infer branches, authors, health or provenance from local UI state.
public struct AtlasCodeGraphResponse: Decodable, Sendable {
    public static let schemaVersion = "atlas.code.graph.v1"

    public let schemaVersion: String
    public let repo: String
    public let generatedAt: String
    public let head: String?
    public let defaultBranch: String?
    public let nodes: [AtlasCodeGraphNode]
    public let worktrees: [AtlasCodeGraphWorktree]
    public let pagination: AtlasCodeGraphPagination
    public let cache: AtlasCodeGraphCache

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, repo, generatedAt, head, defaultBranch, nodes, worktrees, pagination, cache
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.decode(String.self, forKey: .schemaVersion)
        guard schemaVersion == Self.schemaVersion else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: values,
                debugDescription: "Unsupported Atlas Code graph schema."
            )
        }
        self.schemaVersion = schemaVersion
        self.repo = try values.decode(String.self, forKey: .repo)
        self.generatedAt = try values.decode(String.self, forKey: .generatedAt)
        self.head = try values.decodeIfPresent(String.self, forKey: .head)
        self.defaultBranch = try values.decodeIfPresent(String.self, forKey: .defaultBranch)
        self.nodes = try values.decode([AtlasCodeGraphNode].self, forKey: .nodes)
        self.worktrees = try values.decode([AtlasCodeGraphWorktree].self, forKey: .worktrees)
        self.pagination = try values.decode(AtlasCodeGraphPagination.self, forKey: .pagination)
        self.cache = try values.decode(AtlasCodeGraphCache.self, forKey: .cache)
    }
}

public struct AtlasCodeGraphNode: Decodable, Equatable, Sendable, Identifiable {
    public let hash: String
    public let parents: [String]
    public let refs: [String]
    public let authorName: String
    public let authorEmail: String
    public let authoredAt: Int
    /// Commit subject — the headline of the graph screen. Absent on older
    /// server builds: the shell must fall back to the honest empty state and
    /// never fabricate a message.
    public let message: String?

    public var id: String { hash }

    /// The default branch is the norm; a node either belongs to it or it is
    /// the exception the operator must see. `refs` carries names like
    /// "HEAD -> main" and "origin/main".
    public func isOnDefaultBranch(_ defaultBranch: String?) -> Bool {
        guard let defaultBranch, !defaultBranch.isEmpty else { return false }
        for ref in refs {
            let normalized = ref
                .replacingOccurrences(of: "HEAD -> ", with: "")
                .replacingOccurrences(of: "origin/", with: "")
                .trimmingCharacters(in: .whitespaces)
            if normalized == defaultBranch { return true }
        }
        return false
    }
}

/// The color grammar of the graph, stated once so the shell never invents it.
/// Color encodes STATE, never author or commit type — those are already text.
public enum AtlasCodeNodeState: String, Equatable, Sendable {
    /// On the default branch: the norm, the color of the spine.
    case onMain
    /// Off the default branch and flagged by a rule: the exception.
    case violating
    /// Healed by Atlas: the return to main.
    case healed
    /// Reachable history that is neither the spine nor an exception.
    case history
}

public enum AtlasCodeGraphState {
    /// Pure resolution used by the shell and by the checks.
    /// Precedence: healed > violating > onMain > history.
    public static func state(
        for node: AtlasCodeGraphNode,
        defaultBranch: String?,
        violatingHashes: Set<String>,
        healedHashes: Set<String>
    ) -> AtlasCodeNodeState {
        if healedHashes.contains(node.hash) { return .healed }
        if violatingHashes.contains(node.hash) { return .violating }
        if node.isOnDefaultBranch(defaultBranch) { return .onMain }
        return .history
    }
}

public struct AtlasCodeGraphWorktree: Decodable, Equatable, Sendable, Identifiable {
    public let path: String
    public let branch: String?
    public let head: String

    public var id: String { path }
}

public struct AtlasCodeGraphPagination: Decodable, Equatable, Sendable {
    public let limit: Int
    public let before: String?
    public let hasMore: Bool
}

public struct AtlasCodeGraphCache: Decodable, Equatable, Sendable {
    public let strategy: String
    public let refsFingerprint: String
    public let invalidated: Bool
}

/// Public C23 commit identity/provenance contract. Optional provenance fields
/// stay absent when the ledger has no matching record; the app must not turn
/// absence into a synthetic trace or quote.
public struct AtlasCodeProvenance: Decodable, Equatable, Sendable {
    public static let schemaVersion = "atlas.code.provenance.v1"

    public let schemaVersion: String
    public let repo: String
    public let hash: String
    public let commitMessage: String
    public let authorName: String
    public let authorEmail: String
    public let authoredAt: Int
    public let agent: String
    public let traceId: String?
    public let operatorQuote: String?
    public let obra: [String]?
    public let gates: [String]?
    public let traceAgent: String?

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, repo, hash, commitMessage, authorName, authorEmail
        case authoredAt, agent, traceId, operatorQuote, obra, gates, traceAgent
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.decode(String.self, forKey: .schemaVersion)
        guard schemaVersion == Self.schemaVersion else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: values,
                debugDescription: "Unsupported Atlas Code provenance schema."
            )
        }
        self.schemaVersion = schemaVersion
        self.repo = try values.decode(String.self, forKey: .repo)
        self.hash = try values.decode(String.self, forKey: .hash)
        self.commitMessage = try values.decode(String.self, forKey: .commitMessage)
        self.authorName = try values.decode(String.self, forKey: .authorName)
        self.authorEmail = try values.decode(String.self, forKey: .authorEmail)
        self.authoredAt = try values.decode(Int.self, forKey: .authoredAt)
        self.agent = try values.decode(String.self, forKey: .agent)
        self.traceId = try values.decodeIfPresent(String.self, forKey: .traceId)
        self.operatorQuote = try values.decodeIfPresent(String.self, forKey: .operatorQuote)
        self.obra = try values.decodeIfPresent([String].self, forKey: .obra)
        self.gates = try values.decodeIfPresent([String].self, forKey: .gates)
        self.traceAgent = try values.decodeIfPresent(String.self, forKey: .traceAgent)
    }
}

/// The canonical fork/merge geometry from the Atlas Código spec.
public enum AtlasCodeGraphGeometry {
    public static func midpointPath(fromX: Double, fromY: Double, toX: Double, toY: Double) -> String {
        let midpoint = (fromY + toY) / 2
        return "M \(fromX),\(fromY) C \(fromX),\(midpoint) \(toX),\(midpoint) \(toX),\(toY)"
    }

    public static func laneX(index: Int, base: Double = 24, step: Double = 32) -> Double {
        base + Double(max(0, index)) * step
    }
}
