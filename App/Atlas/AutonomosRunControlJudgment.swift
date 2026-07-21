import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive control face for Autônomos loop (WAVE-030) — veto/run organ.
enum AutonomosRunControlFace: Equatable {
    case unbound
    case unregistered
    case running
    case paused
    case killed
    case idle

    var productWord: String {
        switch self {
        case .unbound: return "unbound"
        case .unregistered: return "unregistered"
        case .running: return "running"
        case .paused: return "paused"
        case .killed: return "killed"
        case .idle: return "idle"
        }
    }

    var spokenFace: String {
        switch self {
        case .unbound: return "área de loop não ligada"
        case .unregistered: return "área não registrada no motor"
        case .running: return "loop ao vivo"
        case .paused: return "loop em pausa no servidor"
        case .killed: return "loop encerrado"
        case .idle: return "loop quieto"
        }
    }
}

enum AutonomosRunControlAction: String, Equatable, Identifiable {
    case pause
    case resume
    case kill
    case startExecute
    case startDryRun

    var id: String { rawValue }

    var reasonSheetTitle: String {
        switch self {
        case .pause: return "Pausar o loop"
        case .resume: return "Retomar o loop"
        case .kill: return "Encerrar o loop"
        case .startExecute: return "Iniciar execução"
        case .startDryRun: return "Ensaio (dry-run)"
        }
    }

    var ctaTitle: String {
        switch self {
        case .pause: return "Pausar loop"
        case .resume: return "Retomar loop"
        case .kill: return "Encerrar loop"
        case .startExecute: return "Iniciar loop"
        case .startDryRun: return "Ensaio dry-run"
        }
    }

    var explainer: String {
        switch self {
        case .pause:
            return "Escreve o sinal de pausa no servidor. O loop honra na próxima fronteira segura — não é só opacity da lista local."
        case .resume:
            return "Limpa a pausa e devolve o loop ao ritmo publicado."
        case .kill:
            return "Aciona o kill-switch governado. Exige motivo auditável."
        case .startExecute:
            return "Inicia uma execução real (não ensaio). Motivo e operador obrigatórios."
        case .startDryRun:
            return "Ensaio dry-run: enfileira sem fingir merge. Motivo opcional no ensaio."
        }
    }

    var reasonOptional: Bool {
        switch self {
        case .startDryRun: return true
        default: return false
        }
    }
}

// MARK: - Judgment

enum AutonomosRunControlJudgment {

    /// Auto-bind when exactly one registered area; otherwise nil (honesty multi/zero).
    static func bindAreaID(areas: [AtlasAutonomosArea], defaultArea: String? = nil) -> String? {
        let registered = areas.filter(\.registered)
        if registered.count == 1 { return registered[0].id }
        if let defaultArea,
           let match = registered.first(where: { $0.id == defaultArea }) {
            return match.id
        }
        return nil
    }

    static func face(
        areaSelected: Bool,
        canControl: Bool,
        live: AtlasAutonomosLiveResponse?
    ) -> AutonomosRunControlFace {
        if !areaSelected { return .unbound }
        if !canControl { return .unregistered }
        guard let live else { return .idle }
        if live.isKilled { return .killed }
        if live.isPaused { return .paused }
        if live.isRunning { return .running }
        return .idle
    }

    /// Primary CTA for hub (awaiting decisions still win in HubView before this).
    static func primaryAction(for face: AutonomosRunControlFace) -> AutonomosRunControlAction? {
        switch face {
        case .running: return .pause
        case .paused: return .resume
        case .killed: return .resume // clear path via resume/control if server allows
        case .idle: return .startDryRun
        case .unbound, .unregistered: return nil
        }
    }

    static func secondaryAction(for face: AutonomosRunControlFace) -> AutonomosRunControlAction? {
        switch face {
        case .running: return .kill
        case .idle: return .startExecute
        case .paused: return .kill
        default: return nil
        }
    }

    /// When wire control is available, local unit pause is catalog-only honesty.
    static func demoteLocalPause(canControl: Bool) -> Bool {
        canControl
    }

    static func receiptLine(
        receipt: AtlasAutonomosRunControlResponse?,
        startReceipt: AtlasAutonomosStartRunResponse?,
        error: String?
    ) -> String? {
        if let error, !error.isEmpty { return error }
        if let receipt {
            let verb = receipt.action.rawValue
            let applied = receipt.applied ? "aplicado" : "não aplicado"
            let note = receipt.note.trimmingCharacters(in: .whitespacesAndNewlines)
            if note.isEmpty {
                return "Recibo · \(verb) · \(applied)"
            }
            return "Recibo · \(verb) · \(applied) · \(note)"
        }
        if let start = startReceipt {
            let enq = start.isEnqueued ? "enfileirado" : "não enfileirado"
            return "Start · \(enq)"
        }
        return nil
    }

    static func packLoopFacts(
        face: AutonomosRunControlFace,
        canControl: Bool,
        live: AtlasAutonomosLiveResponse?,
        receipt: AtlasAutonomosRunControlResponse?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("loop_face: \(face.productWord)")
        facts.append("can_control: \(canControl ? "yes" : "no")")
        if let live {
            facts.append("live_phase: \(face.productWord)")
            facts.append("cockpit: \(live.cockpit.status)")
        } else if face == .unbound {
            absences.append("área de loop não ligada — control/start/decide sem selectedArea")
        } else {
            absences.append("live do loop não hidratado")
        }
        if let receipt {
            facts.append("last_control: \(receipt.action.rawValue) · applied=\(receipt.applied)")
        }
        if !canControl, face != .unbound {
            absences.append("área não registrada — canControl=false")
        }
        absences.append("pause da lista local ≠ pause do loop no servidor")
        return (facts, absences)
    }
}
