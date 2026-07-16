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
    /// Quem está na espinha: tudo que a ponta da main alcança pelos pais.
    ///
    /// A ref NÃO é a resposta, e essa foi a falha mais estrutural da tela: o
    /// git decora só a PONTA de cada branch, então `refs` traz "HEAD -> main"
    /// em um nó e vazio nos ancestrais. Medido contra o git real do
    /// atlas-server: dos 200 commits da janela, **197 estão na main e a tela
    /// pintava 6** de dourado. A lei central — dourado = na main — pintava 3%
    /// do que devia, e o resto da espinha aparecia como história cinza, como
    /// se fosse trabalho fora da linha.
    ///
    /// Estar na main é alcançabilidade, não decoração: é uma travessia dos
    /// pais a partir do `head`. Os dois dados já chegam no fio (`head` e
    /// `parents`) e estavam ali, decodificados, sem ninguém usar.
    ///
    /// Uma passada, `Set` de visitados: merge não faz o caminho explodir.
    public static func spine(nodes: [AtlasCodeGraphNode], head: String?) -> Set<String> {
        guard let head, !head.isEmpty else { return [] }

        let parentsOf = Dictionary(nodes.map { ($0.hash, $0.parents) }, uniquingKeysWith: { primeiro, _ in primeiro })
        var naEspinha: Set<String> = []
        var fila = [head]

        while let hash = fila.popLast() {
            guard naEspinha.insert(hash).inserted else { continue }
            // Pai fora da janela é normal (o grafo é paginado) e simplesmente
            // não tem nó para pintar: a travessia para ali, sem drama.
            fila.append(contentsOf: parentsOf[hash] ?? [])
        }

        return naEspinha
    }

    /// Pure resolution used by the shell and by the checks.
    /// Precedence: healed > violating > onMain > history.
    ///
    /// `spineHashes` vem de `spine(nodes:head:)`, calculado UMA vez para o
    /// grafo inteiro — não por nó. Vazio (sem `head` no contrato antigo) faz a
    /// tela cair na ref, que é o comportamento de antes: pinta menos do que
    /// devia, mas nunca pinta de dourado o que não está na main. Errar para o
    /// lado de não afirmar.
    public static func state(
        for node: AtlasCodeGraphNode,
        defaultBranch: String?,
        violatingHashes: Set<String>,
        healedHashes: Set<String>,
        spineHashes: Set<String> = []
    ) -> AtlasCodeNodeState {
        if healedHashes.contains(node.hash) { return .healed }
        if violatingHashes.contains(node.hash) { return .violating }
        if spineHashes.contains(node.hash) { return .onMain }
        if spineHashes.isEmpty, node.isOnDefaultBranch(defaultBranch) { return .onMain }
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
