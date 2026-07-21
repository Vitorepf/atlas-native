import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive Arena Premium “agora” phase face (WAVE-066).
enum ArenaNowFace: Equatable {
    case preparing
    case idle
    case queued
    case running
    case stopping
    case stopped
    case completed
    case failed

    var productWord: String {
        switch self {
        case .preparing: return "preparing"
        case .idle: return "idle"
        case .queued: return "queued"
        case .running: return "running"
        case .stopping: return "stopping"
        case .stopped: return "stopped"
        case .completed: return "completed"
        case .failed: return "failed"
        }
    }

    var spokenFace: String {
        switch self {
        case .preparing: return "preparando a arena"
        case .idle: return "parada"
        case .queued: return "na fila"
        case .running: return "ao vivo"
        case .stopping: return "parando"
        case .stopped: return "parada pelo operador"
        case .completed: return "concluída"
        case .failed: return "interrompida"
        }
    }
}

/// Terminal chrome peel (title · subtitle · symbol · tone key).
struct ArenaNowTerminalChrome: Equatable {
    let title: String
    let subtitle: String
    let symbol: String
    let tone: ArenaPremiumTone
}

// MARK: - Judgment

/// Pure Arena now-phase grammar — face · terminal chrome · spoken · pack.
enum ArenaNowJudgment {

    static func face(
        loadPhase: LoadPhase,
        livePhase: AtlasArenaLivePhase?,
        compositeNil: Bool
    ) -> ArenaNowFace {
        if compositeNil {
            switch loadPhase {
            case .idle, .loading:
                return .preparing
            case .loaded, .failed:
                break
            }
        }
        switch livePhase ?? .idle {
        case .idle: return .idle
        case .queued: return .queued
        case .running: return .running
        case .stopping: return .stopping
        case .stopped: return .stopped
        case .completed: return .completed
        case .failed: return .failed
        }
    }

    static func face(from livePhase: AtlasArenaLivePhase) -> ArenaNowFace {
        switch livePhase {
        case .idle: return .idle
        case .queued: return .queued
        case .running: return .running
        case .stopping: return .stopping
        case .stopped: return .stopped
        case .completed: return .completed
        case .failed: return .failed
        }
    }

    static func face(terminal kind: ArenaPremiumTerminalKind) -> ArenaNowFace {
        switch kind {
        case .stopping: return .stopping
        case .stopped: return .stopped
        case .completed: return .completed
        case .failed: return .failed
        }
    }

    static func terminalChrome(_ kind: ArenaPremiumTerminalKind) -> ArenaNowTerminalChrome {
        switch kind {
        case .stopping:
            return ArenaNowTerminalChrome(
                title: "Parada solicitada",
                subtitle: "Finalizando o caso atual",
                symbol: "hourglass",
                tone: .active
            )
        case .stopped:
            return ArenaNowTerminalChrome(
                title: "Medição parada",
                subtitle: "Resultados parciais preservados",
                symbol: "stop.circle",
                tone: .neutral
            )
        case .completed:
            return ArenaNowTerminalChrome(
                title: "Medição concluída",
                subtitle: "Resultado terminal confirmado",
                symbol: "checkmark.seal",
                tone: .positive
            )
        case .failed:
            return ArenaNowTerminalChrome(
                title: "Medição interrompida",
                subtitle: "O que concluiu foi preservado",
                symbol: "exclamationmark.triangle",
                tone: .negative
            )
        }
    }

    static func idleKicker() -> String { "Arena pronta" }
    static func idleTitle() -> String { "Nada medindo agora" }
    static func idleBody() -> String {
        "Escolha os motores, as suítes e os braços. A Arena cuida da ordem e mostra apenas progresso confirmado."
    }

    static func queuedKicker() -> String { "Na fila" }
    static func queuedTitle() -> String { "Medição programada" }
    static func queuedHonestyLine() -> String {
        "Ainda não iniciado · nenhum progresso foi presumido."
    }

    static func preparingKicker() -> String { "Preparando a Arena" }
    static func preparingTitle() -> String { "Organizando as medições" }

    static func packFacts(
        loadPhase: LoadPhase,
        livePhase: AtlasArenaLivePhase?,
        compositeNil: Bool,
        engineTitle: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(
            loadPhase: loadPhase,
            livePhase: livePhase,
            compositeNil: compositeNil
        )
        facts.append("arena_now_face: \(face.productWord)")
        if let engineTitle, !engineTitle.isEmpty {
            facts.append("arena_engine_title: \(engineTitle)")
        }
        switch face {
        case .preparing:
            absences.append("composite ainda carregando")
        case .idle:
            absences.append("nenhuma medição ao vivo")
        case .queued:
            facts.append("arena_now_queue: true")
        case .running:
            facts.append("arena_now_live: true")
        case .stopping, .stopped, .completed, .failed:
            facts.append("arena_now_terminal: true")
        }
        return (facts, absences)
    }
}
