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

    /// `type` normalizado: minúsculo, PRIMEIRO segmento com escopo
    /// ("fix(ui)+polish(ui)" → "fix(ui)"); nil quando não-convencional.
    static func split(_ message: String) -> (type: String?, subject: String) {
        guard let sep = message.range(of: ": ") else { return (nil, message) }
        let head = String(message[..<sep.lowerBound])
        let subject = String(message[sep.upperBound...]).trimmingCharacters(in: .whitespaces)
        guard !subject.isEmpty, let type = conventionalType(head) else { return (nil, message) }
        return (type, subject)
    }

    private static func conventionalType(_ head: String) -> String? {
        guard !head.isEmpty, head.count <= 40, !head.contains(" ") else { return nil }
        // Primeiro segmento (antes de '+'): o tipo primário do commit.
        let segment = head.split(separator: "+", maxSplits: 1).first.map(String.init) ?? head
        let typeWord = segment.prefix { $0.isLetter }
        let remainder = segment[typeWord.endIndex...]
        // O resto do segmento tem de ser escopo/marca VÁLIDA ("(...)", "!" ou
        // vazio) — senão "fix-me"/"ci-cd" viraria tipo (falso-positivo).
        guard knownTypes.contains(typeWord.lowercased()), isValidScope(remainder) else { return nil }
        return typeWord.lowercased() + remainder
    }

    private static func isValidScope(_ raw: Substring) -> Bool {
        var s = raw
        if s.hasSuffix("!") { s = s.dropLast() }
        if s.isEmpty { return true }
        return s.first == "(" && s.last == ")"
    }
}
