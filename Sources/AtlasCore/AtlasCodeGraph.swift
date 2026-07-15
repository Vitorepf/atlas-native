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

    public var id: String { hash }
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
