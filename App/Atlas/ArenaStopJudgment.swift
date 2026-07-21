import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive Arena stop-sheet face (WAVE-108).
enum ArenaStopFace: Equatable {
    case blocked
    case ready

    var productWord: String {
        switch self {
        case .blocked: return "blocked"
        case .ready: return "ready"
        }
    }

    var spokenFace: String {
        switch self {
        case .blocked:
            return "parada bloqueada, preencha operador e motivo"
        case .ready:
            return "pronta para confirmar a parada"
        }
    }
}

// MARK: - Judgment

/// Pure Arena stop governance grammar — face · spoken · pack.
enum ArenaStopJudgment {

    static let navigationTitle = "Parar"
    static let kicker = "Ação governada"
    static let heroTitle = "Parar a medição?"
    static let bodyCopy =
        "O caso atual termina antes da parada. Casos concluídos e resultados parciais são preservados."
    static let actorLabel = "Operador"
    static let reasonLabel = "Motivo"
    static let actorPlaceholder = "quem autoriza"
    static let reasonPlaceholder = "por que parar agora"
    static let confirmTitle = "Confirmar parada"
    static let closeSpoken = "fechar confirmação"
    static let closeHint = "mantém a medição em execução"
    static let confirmHint = "envia a parada governada com operador e motivo"

    static func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func face(actor: String, reason: String) -> ArenaStopFace {
        canSubmit(actor: actor, reason: reason) ? .ready : .blocked
    }

    static func canSubmit(actor: String, reason: String) -> Bool {
        !trimmed(actor).isEmpty && !trimmed(reason).isEmpty
    }

    static func spokenSheet(suite: String) -> String {
        "parar medição \(suite), \(face(actor: "", reason: "").spokenFace)"
    }

    static func spokenSheet(actor: String, reason: String, suite: String) -> String {
        "parar medição \(suite), \(face(actor: actor, reason: reason).spokenFace)"
    }

    static func spokenConfirm(actor: String, reason: String) -> String {
        let face = face(actor: actor, reason: reason)
        switch face {
        case .blocked:
            return "confirmar parada indisponível, \(face.spokenFace)"
        case .ready:
            return "confirmar parada, operador \(trimmed(actor))"
        }
    }

    static func spokenReceipt(_ receipt: AtlasArenaStopReceipt) -> String {
        "parada registrada, medição \(receipt.measurementIdPublic)"
    }

    static func packFacts(
        actor: String,
        reason: String,
        hasMatchingReceipt: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(actor: actor, reason: reason)
        facts.append("arena_stop_face: \(face.productWord)")
        if trimmed(actor).isEmpty {
            absences.append("operador da parada vazio")
        } else {
            facts.append("stop_actor_present: true")
        }
        if trimmed(reason).isEmpty {
            absences.append("motivo da parada vazio")
        } else {
            facts.append("stop_reason_present: true")
        }
        if hasMatchingReceipt {
            facts.append("stop_receipt: published")
        } else {
            absences.append("sem recibo de parada nesta medição")
        }
        return (facts, absences)
    }
}
