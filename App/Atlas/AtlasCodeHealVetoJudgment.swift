import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive heal veto face for Código receipt (WAVE-048).
enum AtlasCodeHealVetoFace: Equatable {
    case absent
    case completed
    case blocked(String)
    case vetoOpen
    case vetoClosed
    case undoFailed(String)

    var productWord: String {
        switch self {
        case .absent: return "absent"
        case .completed: return "completed"
        case .blocked: return "blocked"
        case .vetoOpen: return "veto_open"
        case .vetoClosed: return "veto_closed"
        case .undoFailed: return "undo_failed"
        }
    }

    var kicker: String {
        switch self {
        case .absent: return "Cura"
        case .completed: return "Curado sozinho"
        case .blocked: return "Cura bloqueada"
        case .vetoOpen: return "Veto aberto"
        case .vetoClosed: return "Veto encerrado"
        case .undoFailed: return "Veto falhou"
        }
    }

    var spokenFace: String {
        switch self {
        case .absent:
            return "sem recibo de cura"
        case .completed:
            return "curado sozinho, sem janela de veto ativa"
        case .blocked(let reason):
            return "cura bloqueada, \(reason)"
        case .vetoOpen:
            return "janela de veto aberta, desfazer com recibo disponível"
        case .vetoClosed:
            return "janela de veto encerrada"
        case .undoFailed(let message):
            return "falha ao desfazer, \(message)"
        }
    }
}

// MARK: - Judgment

/// Pure heal veto grammar — face · canVeto · pack · spoken.
enum AtlasCodeHealVetoJudgment {

    static func completedStepCount(_ heal: AtlasCodeHealResponse) -> Int {
        heal.stepReceipts.filter { $0.status == "completed" }.count
    }

    static func undoExpiresAt(_ heal: AtlasCodeHealResponse) -> String? {
        heal.stepReceipts.compactMap(\.undoExpiresAt).first
    }

    static func canVeto(_ heal: AtlasCodeHealResponse) -> Bool {
        heal.healId != nil && AtlasCodeUndoWindow.isOpen(expiresAt: undoExpiresAt(heal))
    }

    static func face(
        heal: AtlasCodeHealResponse?,
        undoError: String?
    ) -> AtlasCodeHealVetoFace {
        if let err = undoError?.trimmingCharacters(in: .whitespacesAndNewlines), !err.isEmpty {
            return .undoFailed(err)
        }
        guard let heal else { return .absent }
        if let blocked = heal.blocked, !blocked.isEmpty {
            return .blocked(blocked)
        }
        if canVeto(heal) {
            return .vetoOpen
        }
        if completedStepCount(heal) > 0 {
            // Completed but window closed or no healId for undo.
            if heal.healId != nil {
                return .vetoClosed
            }
            return .completed
        }
        return .completed
    }

    static func packFacts(
        heal: AtlasCodeHealResponse?,
        undoError: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(heal: heal, undoError: undoError)
        facts.append("heal_veto_face: \(face.productWord)")
        guard let heal else {
            absences.append("recibo de cura não hidratado neste recorte")
            return (facts, absences)
        }
        facts.append("heal_mode: \(heal.mode)")
        facts.append("heal_steps: \(heal.stepReceipts.count)")
        facts.append("heal_completed_steps: \(completedStepCount(heal))")
        facts.append("can_veto: \(canVeto(heal))")
        if let note = AtlasCodeUndoWindow.note(expiresAt: undoExpiresAt(heal)) {
            facts.append("veto_window: \(note)")
        } else {
            absences.append("janela de veto sem nota publicada")
        }
        if let err = undoError, !err.isEmpty {
            facts.append("undo_error: \(err)")
        } else {
            absences.append("nenhuma falha de veto neste recorte")
        }
        if heal.healId == nil {
            absences.append("heal_id ausente — veto indisponível")
        }
        return (facts, absences)
    }

    static func spokenUndoError(_ err: String) -> String {
        "falha ao desfazer, \(err)"
    }

    static func spokenSheet(
        heal: AtlasCodeHealResponse,
        undoError: String?
    ) -> String {
        var parts = ["recibo de cura", heal.mode]
        let face = face(heal: heal, undoError: undoError)
        parts.append(face.spokenFace)
        if heal.stepReceipts.isEmpty {
            parts.append("sem passos no recibo")
        } else {
            let done = completedStepCount(heal)
            parts.append("\(heal.stepReceipts.count) passos, \(done) concluídos")
        }
        return parts.joined(separator: ", ")
    }
}
