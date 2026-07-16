import Foundation

/// M3 v2 · o workspace real do operador.
///
/// O disco tem pastas de produto (Atlas/, blackink/) que contêm repositórios,
/// e repositórios soltos. Pasta NÃO é repositório quebrado — tratá-la assim
/// era erro de modelo. A tela mostra RECENTES (o trabalho vivo) e PASTAS
/// (a verdade completa, sem duplicar em lista solta).
public struct AtlasCodeWorkspaceResponse: Decodable, Equatable, Sendable {
    public static let schemaVersion = "atlas.code.repos.v2"

    public let schemaVersion: String
    public let generatedAt: String
    public let workspaceRoot: String?
    public let recents: [AtlasCodeRepoRef]
    public let folders: [AtlasCodeFolder]
    public let loose: [AtlasCodeRepoRef]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, generatedAt, workspaceRoot, recents, folders, loose
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Code workspace schema.")
        self.schemaVersion = schemaVersion
        self.generatedAt = try values.decode(String.self, forKey: .generatedAt)
        self.workspaceRoot = try values.decodeIfPresent(String.self, forKey: .workspaceRoot)
        self.recents = try values.decodeIfPresent([AtlasCodeRepoRef].self, forKey: .recents) ?? []
        self.folders = try values.decodeIfPresent([AtlasCodeFolder].self, forKey: .folders) ?? []
        self.loose = try values.decodeIfPresent([AtlasCodeRepoRef].self, forKey: .loose) ?? []
    }

    /// Quantos repositórios o Atlas conhece — a única contagem que informa.
    public var repositoryCount: Int {
        folders.reduce(0) { $0 + $1.repos.count } + loose.count
    }
}

public struct AtlasCodeRepoRef: Decodable, Equatable, Sendable, Identifiable {
    public let slug: String
    public let name: String
    public let path: String
    /// Pasta de produto a que pertence; nil = repositório solto.
    public let folder: String?
    /// Epoch do último commit. Ausente = sem história legível — e ausência
    /// jamais vira "1970".
    public let lastCommitAt: Int?

    public var id: String { path }
}

public struct AtlasCodeFolder: Decodable, Equatable, Sendable, Identifiable {
    public let slug: String
    public let name: String
    public let repositories: Int
    public let lastCommitAt: Int?
    public let repos: [AtlasCodeRepoRef]

    public var id: String { slug }
}

/// Tempo relativo humano, curto — o mesmo vocabulário do grafo.
public enum AtlasCodeAge {
    public static func short(from epoch: Int?, now: Date = Date()) -> String? {
        guard let epoch else { return nil }
        let seconds = max(0, Int(now.timeIntervalSince1970) - epoch)
        switch seconds {
        case ..<120: return "agora"
        case ..<3600: return "\(seconds / 60)min"
        case ..<86_400: return "\(seconds / 3600)h"
        case ..<172_800: return "ontem"
        case ..<2_592_000: return "\(seconds / 86_400)d"
        default: return "\(seconds / 2_592_000)mês"
        }
    }
}
