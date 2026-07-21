import Foundation

// MARK: - Types

/// Exclusive governed-action reason sheet face (WAVE-098).
enum AutonomosReasonFace: Equatable {
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
            return "confirmar indisponível"
        case .ready:
            return "pronto para confirmar"
        }
    }
}

// MARK: - Judgment

/// Pure governed reason-sheet grammar — face · canSubmit · spoken · pack.
enum AutonomosReasonJudgment {

    static let navigationTitle = "Confirmar ação"
    static let sectionAction = "Ação governada"
    static let sectionOperator = "Operador"
    static let actorPlaceholder = "Quem autoriza"
    static let reasonPlaceholder = "Motivo auditável"
    static let confirmTitle = "Confirmar"
    static let cancelTitle = "Cancelar"
    static let cancelSpoken = "cancelar ação governada"
    static let cancelHint = "fecha sem registrar recibo"
    static let actorHint = "nome de quem autoriza a ação governada"
    static let reasonHintRequired = "motivo auditável registrado no ledger"
    static let reasonHintOptional = "motivo auditável opcional no ensaio"

    // MARK: Face / submit

    static func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func face(
        actor: String,
        reason: String,
        reasonOptional: Bool
    ) -> AutonomosReasonFace {
        canSubmit(actor: actor, reason: reason, reasonOptional: reasonOptional)
            ? .ready
            : .blocked
    }

    static func canSubmit(
        actor: String,
        reason: String,
        reasonOptional: Bool
    ) -> Bool {
        !trimmed(actor).isEmpty
            && (reasonOptional || !trimmed(reason).isEmpty)
    }

    // MARK: Spoken

    static func spokenSheet(actionTitle: String) -> String {
        "confirmar ação governada, \(actionTitle.lowercased())"
    }

    static func spokenConfirm(
        actionTitle: String,
        actor: String,
        reason: String,
        reasonOptional: Bool
    ) -> String {
        let f = face(actor: actor, reason: reason, reasonOptional: reasonOptional)
        switch f {
        case .ready:
            return "confirmar \(actionTitle.lowercased())"
        case .blocked:
            return "confirmar indisponível, preencha operador e motivo"
        }
    }

    static func reasonSectionTitle(reasonOptional: Bool) -> String {
        reasonOptional ? "Motivo (opcional no ensaio)" : "Motivo"
    }

    static func reasonFieldHint(reasonOptional: Bool) -> String {
        reasonOptional ? reasonHintOptional : reasonHintRequired
    }

    // MARK: Pack

    static func packFacts(
        actionTitle: String,
        actor: String,
        reason: String,
        reasonOptional: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let f = face(actor: actor, reason: reason, reasonOptional: reasonOptional)
        facts.append("reason_face: \(f.productWord)")
        facts.append("reason_action: \(actionTitle)")
        facts.append("reason_optional: \(reasonOptional ? "yes" : "no")")
        if trimmed(actor).isEmpty {
            absences.append("operador autorizador vazio")
        } else {
            facts.append("reason_actor_present: true")
        }
        if trimmed(reason).isEmpty {
            if reasonOptional {
                facts.append("reason_body: optional_empty")
            } else {
                absences.append("motivo auditável vazio")
            }
        } else {
            facts.append("reason_body_present: true")
        }
        return (facts, absences)
    }
}
