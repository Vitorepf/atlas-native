import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive editorial signature face (WAVE-069).
enum EditorialSignatureFace: Equatable {
    case present(who: String)
    case absent

    var productWord: String {
        switch self {
        case .present: return "present"
        case .absent: return "absent"
        }
    }

    var spokenFace: String {
        switch self {
        case .present(let who):
            return "resposta de \(who)"
        case .absent:
            return "assinatura ausente"
        }
    }
}

// MARK: - Judgment

/// Pure editorial-turn grammar — signature · feedback · pack.
enum EditorialTurnJudgment {

    static let spokenFinalAnswerKicker = "resposta final"
    static let copyLongPressHint = "pressionar e segurar copia a resposta"
    static let feedbackHint = "envia feedback ao roteamento do Atlas para este turno"

    static func signatureWho(provider: String?, model: String?) -> String? {
        if let model, !model.isEmpty, !model.hasSuffix("_default") { return model }
        if let provider, !provider.isEmpty {
            let word = providerWord(provider)
            return word.isEmpty ? provider : word
        }
        return nil
    }

    /// Provider product word — same map as EditorialTurn `providerWord` free fn.
    static func providerWord(_ provider: String) -> String {
        let x = provider.lowercased()
        for (k, v) in [
            ("claude", "claude"), ("codex", "codex"), ("gemini", "gemini"),
            ("hermes", "hermes"), ("minimax", "minimax"),
            ("council", "conselho"), ("conselho", "conselho")
        ] where x.contains(k) {
            return v
        }
        return x
    }

    static func face(provider: String?, model: String?) -> EditorialSignatureFace {
        if let who = signatureWho(provider: provider, model: model) {
            return .present(who: who)
        }
        return .absent
    }

    static func spokenSignature(
        provider: String?,
        model: String?,
        elapsedMs: Int?
    ) -> String {
        guard let who = signatureWho(provider: provider, model: model) else {
            return ""
        }
        if let ms = elapsedMs, ms > 0 {
            return "resposta de \(who), em \(humanDuration(ms))"
        }
        return "resposta de \(who)"
    }

    static func spokenUserMessage(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "mensagem sua, vazia" : "mensagem sua, \(trimmed)"
    }

    static func spokenFeedbackBase(kind: FeedbackKind) -> String {
        switch kind {
        case .util: return "marcar resposta como útil"
        case .contexto: return "marcar contexto errado"
        case .longo: return "marcar resposta longa demais"
        case .fraco: return "marcar resposta fraca"
        }
    }

    static func spokenFeedbackLabel(kind: FeedbackKind, active: Bool) -> String {
        let base = spokenFeedbackBase(kind: kind)
        return active ? "\(base), selecionado" : base
    }

    /// Same duration honesty as EditorialTurn free `humanDuration`.
    static func humanDuration(_ ms: Int) -> String {
        if ms < 1000 { return "um instante" }
        if ms < 60000 {
            return String(format: "%.1f s", Double(ms) / 1000)
                .replacingOccurrences(of: ".", with: ",")
        }
        return "\(ms / 60000) min"
    }

    static func packFacts(
        provider: String?,
        model: String?,
        elapsedMs: Int?,
        feedbackAction: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(provider: provider, model: model)
        facts.append("editorial_signature_face: \(face.productWord)")
        switch face {
        case .present(let who):
            facts.append("editorial_who: \(who)")
        case .absent:
            absences.append("assinatura do turno ausente")
        }
        if let ms = elapsedMs, ms > 0 {
            facts.append("editorial_elapsed_ms: \(ms)")
        }
        if let feedbackAction, !feedbackAction.isEmpty {
            facts.append("editorial_feedback: \(feedbackAction)")
        } else {
            absences.append("sem feedback do operador neste turno")
        }
        return (facts, absences)
    }
}
