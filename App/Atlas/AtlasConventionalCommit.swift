import Foundation

/// Divide um assunto de commit convencional "tipo(escopo): frase" em
/// (tipo, frase). Presentation-only — só separa quando o prefixo é MESMO um
/// tipo convencional conhecido; mensagem comum fica inteira, tipo nil.
/// Ausência de tipo nunca vira tipo inventado (lei da honestidade).
enum AtlasConventionalCommit {
    // ponytail: whitelist de tipos — evita falso-positivo de mensagem comum
    // com ":" ("nota: isso"). Cobre os tipos usados no Atlas + os padrão.
    private static let knownTypes: Set<String> = [
        "feat", "fix", "docs", "polish", "refactor", "chore",
        "test", "style", "perf", "build", "ci", "revert", "wip"
    ]

    static func split(_ message: String) -> (type: String?, subject: String) {
        guard let sep = message.range(of: ": ") else { return (nil, message) }
        let head = String(message[..<sep.lowerBound])
        let subject = String(message[sep.upperBound...]).trimmingCharacters(in: .whitespaces)
        guard !subject.isEmpty, isConventionalHead(head) else { return (nil, message) }
        return (head, subject)
    }

    private static func isConventionalHead(_ head: String) -> Bool {
        guard !head.isEmpty, head.count <= 40, !head.contains(" ") else { return false }
        // O tipo é o primeiro token de letras (antes de '(', '!', '+', '/').
        let firstToken = String(head.prefix { $0.isLetter }).lowercased()
        return knownTypes.contains(firstToken)
    }
}
