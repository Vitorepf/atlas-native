import Foundation

/// Public C22 topology contract. The app receives Git facts only; it does not
/// infer branches, authors, health or provenance from local UI state.
public struct AtlasCodeGraphResponse: Decodable, Sendable {
    public static let schemaVersion = "atlas.code.graph.v1"

    public let schemaVersion: String
    public let repo: String
    public let generatedAt: String
    /// Onde o operador está parado. NÃO é de onde a espinha nasce.
    public let head: String?
    public let defaultBranch: String?
    /// A ponta da TRUNK — a origem da espinha dourada.
    ///
    /// Existe porque `head` e a trunk são fatos diferentes e confundi-los
    /// inverte a lei da cor: estando numa obra, traçar a espinha do `head`
    /// pinta a obra inteira de dourado — a exceção vestida de norma, o oposto
    /// do que o operador precisa ver. Medido no nivor-back-end (trunk =
    /// `production`): 173 nós pela trunk, 167 pelo head, conjuntos diferentes.
    ///
    /// Ausente quando a trunk é ambígua ou o servidor é antigo: aí a tela pinta
    /// menos do que devia, nunca pinta errado.
    public let trunkHead: String?
    public let nodes: [AtlasCodeGraphNode]
    public let worktrees: [AtlasCodeWorktree]
    public let pagination: AtlasCodeGraphPagination

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, repo, generatedAt, head, defaultBranch, trunkHead, nodes, worktrees, pagination
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Code graph schema.")
        self.schemaVersion = schemaVersion
        self.repo = try values.decode(String.self, forKey: .repo)
        self.generatedAt = try values.decode(String.self, forKey: .generatedAt)
        self.head = try values.decodeIfPresent(String.self, forKey: .head)
        self.defaultBranch = try values.decodeIfPresent(String.self, forKey: .defaultBranch)
        self.trunkHead = try values.decodeIfPresent(String.self, forKey: .trunkHead)
        self.nodes = try values.decode([AtlasCodeGraphNode].self, forKey: .nodes)
        self.worktrees = try values.decodeIfPresent([AtlasCodeWorktree].self, forKey: .worktrees) ?? []
        self.pagination = try values.decode(AtlasCodeGraphPagination.self, forKey: .pagination)
    }
}

public struct AtlasCodeWorktree: Decodable, Equatable, Sendable, Identifiable {
    public let pathLabel: String
    public let branch: String?
    public let head: String?
    public let state: String?

    public var id: String {
        [pathLabel, branch, head].compactMap { $0 }.joined(separator: ":")
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

public struct AtlasCodeGraphPagination: Decodable, Equatable, Sendable {
    public let limit: Int
    public let before: String?
    public let hasMore: Bool
}

// AtlasCodeGraphCache foi deletado: era teatro. `invalidated` prometia dizer se
// o grafo mudou desde a última carga, mas o serviço não é singleton — sempre
// devolvia false — e nenhuma tela lia. Campo que não pode ser verdadeiro é pior
// que campo ausente.
