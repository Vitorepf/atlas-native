import Foundation

// MARK: - Types

/// Exclusive conversation messages surface face (WAVE-072).
enum ConversationMessagesFace: Equatable {
    case loadFail
    case empty
    case messages(Int)

    var productWord: String {
        switch self {
        case .loadFail: return "load_fail"
        case .empty: return "empty"
        case .messages: return "messages"
        }
    }

    var spokenFace: String {
        switch self {
        case .loadFail:
            return "falha ao carregar conversa"
        case .empty:
            return "conversa vazia"
        case .messages(let n):
            let noun = n == 1 ? "turno" : "turnos"
            return "\(n) \(noun)"
        }
    }
}

// MARK: - Judgment

/// Pure messages-surface grammar — face · spoken · pack.
enum ConversationMessagesJudgment {

    static let scrollFABLabel = "ir para o fim da conversa"
    static let scrollFABHint = "volta às mensagens mais recentes"
    static let changeReviewHint = "abre arquivos, diff e provas desta execução"

    static func face(
        hasLoadError: Bool,
        turnCount: Int
    ) -> ConversationMessagesFace {
        if hasLoadError { return .loadFail }
        if turnCount <= 0 { return .empty }
        return .messages(turnCount)
    }

    static func spokenMessages(turnCount: Int) -> String {
        let face = face(hasLoadError: false, turnCount: turnCount)
        switch face {
        case .empty:
            return "conversa, vazia"
        case .messages(let n):
            let noun = n == 1 ? "turno" : "turnos"
            return "conversa, \(n) \(noun)"
        case .loadFail:
            return "conversa, falha ao carregar"
        }
    }

    static func spokenChangeReview(patchCount: Int) -> String {
        if patchCount > 0 {
            let noun = patchCount == 1 ? "patch" : "patches"
            return "revisar mudanças, \(patchCount) \(noun)"
        }
        return "revisar mudanças desta execução"
    }

    static func packFacts(
        hasLoadError: Bool,
        turnCount: Int
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(hasLoadError: hasLoadError, turnCount: turnCount)
        facts.append("messages_face: \(face.productWord)")
        switch face {
        case .loadFail:
            absences.append("conversa falhou ao carregar")
        case .empty:
            absences.append("conversa sem turnos")
            facts.append("messages_turns: 0")
        case .messages(let n):
            facts.append("messages_turns: \(n)")
        }
        return (facts, absences)
    }
}
