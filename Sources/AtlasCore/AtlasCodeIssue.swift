import Foundation

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
