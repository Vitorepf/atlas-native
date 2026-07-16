import Foundation

/// M5 espelho. O host é ADAPTADOR (GitHub hoje, origin da Cursor amanhã): a
/// verdade mora no Mac, lá fora é cópia. Ausências são ditas, nunca viram
/// zero: `mirror == nil` significa "sem espelho configurado", e
/// `pending == nil` significa "não sei ainda" — não "nada a enviar".
public struct AtlasCodeMirrorResponse: Decodable, Equatable, Sendable {
    public static let schemaVersion = "atlas.code.mirror.v1"

    public let schemaVersion: String
    public let repo: String
    public let generatedAt: String
    public let branch: String?
    public let mirror: Mirror?
    public let pending: Pending?
    public let scan: Scan?
    public let reason: String?

    public struct Mirror: Decodable, Equatable, Sendable {
        public let name: String
        public let host: String?
        public let upstream: String?
    }

    public struct Pending: Decodable, Equatable, Sendable {
        public let commits: Int
    }

    public struct Scan: Decodable, Equatable, Sendable {
        public let ran: Bool
        public let findings: [Finding]
        public let blocked: Bool

        public struct Finding: Decodable, Equatable, Sendable, Identifiable {
            public let rule: String
            public let line: Int
            public var id: String { "\(rule):\(line)" }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, repo, generatedAt, branch, mirror, pending, scan, reason
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.decode(String.self, forKey: .schemaVersion)
        guard schemaVersion == Self.schemaVersion else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: values,
                debugDescription: "Unsupported Atlas Code mirror schema."
            )
        }
        self.schemaVersion = schemaVersion
        self.repo = try values.decode(String.self, forKey: .repo)
        self.generatedAt = try values.decode(String.self, forKey: .generatedAt)
        self.branch = try values.decodeIfPresent(String.self, forKey: .branch)
        self.mirror = try values.decodeIfPresent(Mirror.self, forKey: .mirror)
        self.pending = try values.decodeIfPresent(Pending.self, forKey: .pending)
        self.scan = try values.decodeIfPresent(Scan.self, forKey: .scan)
        self.reason = try values.decodeIfPresent(String.self, forKey: .reason)
    }

    /// O que a tela diz — em linguagem humana, sem jargão de máquina.
    public enum State: Equatable, Sendable {
        case noMirror(reason: String)
        case unknown(reason: String)
        case mirrored
        case pending(commits: Int)
        case blocked(rules: [String])
    }

    public var state: State {
        // `remote_unreadable` é FALHA de git, não ausência de remote: o
        // servidor os distingue, e o card não podia colapsá-los em "sem
        // espelho configurado" — isso é a falha vestida de fato, mandando o
        // operador configurar um remote que talvez já exista. Falha vira
        // `.unknown` (cinza, "estado ainda desconhecido"), que não afirma nada.
        if mirror == nil, reason == "remote_unreadable" {
            return .unknown(reason: "remote_unreadable")
        }
        guard mirror != nil else { return .noMirror(reason: reason ?? "no_remote_configured") }
        guard let pending else { return .unknown(reason: reason ?? "upstream_unknown") }
        if let scan, scan.blocked {
            return .blocked(rules: Array(Set(scan.findings.map(\.rule))).sorted())
        }
        return pending.commits == 0 ? .mirrored : .pending(commits: pending.commits)
    }
}
