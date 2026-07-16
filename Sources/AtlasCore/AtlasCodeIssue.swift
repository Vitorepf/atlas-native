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

    /// A frase com a linha pelo NOME dela.
    ///
    /// As frases canônicas dizem "main" porque a regra pétrea se chama assim —
    /// mas metade da frota tem trunk `production`, e a cápsula da mesma tela já
    /// fala o nome real ("2 desvios da production"). A linha da issue dizendo
    /// "fora da main" ao lado é a tela discutindo consigo mesma. Com a trunk
    /// dita, a frase troca a palavra; sem trunk (ambígua/servidor antigo), fica
    /// "main", que é o canon.
    public func headline(trunk: String?) -> String {
        guard let trunk, !trunk.isEmpty, trunk != "main" else { return headline }
        return headline.replacingOccurrences(of: "à main", with: "à \(trunk)")
            .replacingOccurrences(of: "da main", with: "da \(trunk)")
    }

    /// A lei em português, no singular, com a linha pelo nome — para um caso só.
    public static func law(_ ruleId: String, trunk: String?) -> String {
        AtlasCodeIssue(ruleId: ruleId, count: 1, severity: "high", oldestDays: nil).headline(trunk: trunk)
    }

    /// A lei em português, no singular — para um caso só.
    ///
    /// O grafo mostrava `worktree_allowlist` cru na linha do commit e
    /// "FORA DA MAIN · WORKTREE_ALLOWLIST" no cabeçalho da folha: vocabulário
    /// de máquina na cara do operador, na tela em que ele decide se apaga
    /// trabalho. O tradutor já existia aqui e o grafo não o usava — o radar
    /// fala português desde sempre e o mapa continuava falando snake_case.
    ///
    /// Regra nova do canon não vira mentira: vira o id legível, que é dizer
    /// "não tenho frase para isto" sem esconder o que é.
    public static func law(_ ruleId: String) -> String {
        AtlasCodeIssue(ruleId: ruleId, count: 1, severity: "high", oldestDays: nil).headline
    }

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
