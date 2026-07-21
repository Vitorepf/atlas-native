import Foundation
import AtlasCore

// WAVE-022 — exclusive execution face for in-app conversation (pairs with WAVE-018 glance).

enum ConversationExecutionFace: String, Equatable {
    case finished
    case reconnect
    case paused
    case multiAgent
    case running
    case quiet
}

enum ConversationExecutionPhase {
    /// Priority: finished → reconnect → paused → multiAgent → running → quiet.
    static func face(for bubble: ChatBubble) -> ConversationExecutionFace {
        if !bubble.streaming, bubble.executionPresentationState == nil, bubble.agents.isEmpty {
            // Terminal stream: no live chrome if nothing executing.
            if bubble.activities.isEmpty { return .quiet }
        }
        if isFinished(bubble) { return .finished }
        if bubble.showsReconnectSurface { return .reconnect }
        if isPaused(bubble) { return .paused }
        if bubble.agents.count >= 2 { return .multiAgent }
        if bubble.streaming || bubble.executionProgress != nil || !bubble.agents.isEmpty {
            return .running
        }
        return .quiet
    }

    static func isFinished(_ bubble: ChatBubble) -> Bool {
        guard let state = bubble.executionPresentationState else {
            return !bubble.streaming && bubble.reconnectNotice == nil && bubble.agents.isEmpty
        }
        // Presentation kinds that mean terminal (never invent).
        switch state.kind {
        case .completed, .failed:
            return true
        default:
            break
        }
        if state.timer?.timing == .finished { return true }
        return false
    }

    static func isPaused(_ bubble: ChatBubble) -> Bool {
        if bubble.executionPresentationState?.timer?.timing == .paused { return true }
        return bubble.executionPresentationState?.title
            .localizedCaseInsensitiveContains("paus") == true
    }

    /// WAVE-012 dual-surface: strip owns reconnect primary while streaming+reconnect.
    static func ribbonShowsReconnectBanner(_ bubble: ChatBubble) -> Bool {
        let face = face(for: bubble)
        guard face == .reconnect || bubble.showsReconnectSurface else { return false }
        // Silence ribbon primary when strip is the owner.
        if bubble.streaming && bubble.showsReconnectSurface { return false }
        return true
    }

    /// Watchdog only meaningful while live and not finished.
    static func ribbonShowsSilenceWatchdog(_ bubble: ChatBubble) -> Bool {
        let face = face(for: bubble)
        return face == .running || face == .multiAgent || face == .paused
            || (face == .reconnect && bubble.streaming)
    }

    static func spokenFace(_ face: ConversationExecutionFace) -> String {
        switch face {
        case .finished: return "execução concluída"
        case .reconnect: return "reconectando"
        case .paused: return "execução em pausa"
        case .multiAgent: return "várias lanes ativas"
        case .running: return "execução ao vivo"
        case .quiet: return "sem execução ativa"
        }
    }
}
