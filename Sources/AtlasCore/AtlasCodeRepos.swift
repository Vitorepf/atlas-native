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
    /// Agrupado por regra: a tela conta a história, não lista ids.
    public let issues: [AtlasCodeIssue]?

    public var id: String { slug }

    /// O que a linha do radar diz. Silêncio é um estado legítimo — e o mais
    /// comum, porque saudável não grita.
    public enum Signal: Equatable, Sendable {
        case silent
        case exception(count: Int, issues: [AtlasCodeIssue])
        case unreadable(reason: String)
        case scanUnavailable
    }

    public var signal: Signal {
        if !readable { return .unreadable(reason: unreadableReason ?? "repository_unreadable") }
        if scan == "unavailable" { return .scanUnavailable }
        if let violations, violations > 0 { return .exception(count: violations, issues: issues ?? []) }
        return .silent
    }
}

/// Um problema real, agrupado. A regra do canon é um id de máquina; esta
/// projeção existe para que a TELA fale português — nunca `obra_return_deadline`.
public struct AtlasCodeIssue: Decodable, Equatable, Sendable, Identifiable {
    public let ruleId: String
    public let count: Int
    public let severity: String
    /// Idade do caso mais antigo. Ausente quando não foi possível medir —
    /// jamais estimada.
    public let oldestDays: Int?

    public var id: String { ruleId }

    public init(ruleId: String, count: Int, severity: String, oldestDays: Int?) {
        self.ruleId = ruleId
        self.count = count
        self.severity = severity
        self.oldestDays = oldestDays
    }

    public var isSevere: Bool { severity == "high" }

    /// A frase que o operador lê. Plural resolvido, sujeito explícito.
    public var headline: String {
        switch ruleId {
        case "obra_return_deadline":
            return count == 1 ? "1 obra nunca voltou à main" : "\(count) obras nunca voltaram à main"
        case "orphan_branch":
            return count == 1 ? "1 branch abandonada" : "\(count) branches abandonadas"
        case "main_only":
            return count == 1 ? "1 branch fora da main" : "\(count) branches fora da main"
        case "worktree_allowlist":
            return count == 1 ? "1 worktree fora do lugar" : "\(count) worktrees fora do lugar"
        case "mirror_drift":
            return count == 1 ? "1 espelho desatualizado" : "\(count) espelhos desatualizados"
        default:
            // Regra nova do canon: mostra o id em vez de mentir, mas legível.
            let readable = ruleId.replacingOccurrences(of: "_", with: " ")
            return count == 1 ? "1 caso de \(readable)" : "\(count) casos de \(readable)"
        }
    }

    /// O detalhe temporal, quando medido: "a mais antiga há 22 dias".
    public var ageNote: String? {
        guard let oldestDays else { return nil }
        let subject: String
        switch ruleId {
        case "obra_return_deadline": subject = count == 1 ? "há" : "a mais antiga há"
        case "orphan_branch", "main_only": subject = count == 1 ? "há" : "a mais antiga há"
        default: subject = count == 1 ? "há" : "o mais antigo há"
        }
        if oldestDays == 0 { return "\(subject) menos de um dia" }
        return oldestDays == 1 ? "\(subject) 1 dia" : "\(subject) \(oldestDays) dias"
    }
}
