import Foundation
import AtlasCore

// WAVE-022/023 — exclusive execution face for in-app presence (pairs with WAVE-018 glance).
// Product words: finished | reconnect | paused | multi | running | quiet

enum ConversationExecutionFace: String, Equatable {
    case finished
    case reconnect
    case paused
    case multiAgent
    case running
    case quiet

    /// Shared product vocabulary (ribbon ≡ strip ≡ LiveNow ≡ glance multi).
    var productWord: String {
        switch self {
        case .finished: return "finished"
        case .reconnect: return "reconnect"
        case .paused: return "paused"
        case .multiAgent: return "multi"
        case .running: return "running"
        case .quiet: return "quiet"
        }
    }
}

/// Attention overlays — never faces (WAVE-023).
enum ConversationExecutionAttention: String, Equatable {
    case awaiting
    case recovering
    case replanning
    case failed
    case decision
}

enum ConversationExecutionPhase {
    /// Priority: finished → reconnect → paused → multiAgent → running → quiet.
    static func face(for bubble: ChatBubble) -> ConversationExecutionFace {
        if !bubble.streaming, bubble.executionPresentationState == nil, bubble.agents.isEmpty {
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

    static func face(for state: AtlasExecutionPresentationState) -> ConversationExecutionFace {
        if state.timer?.timing == .finished { return .finished }
        if state.timer?.timing == .paused { return .paused }
        switch state.kind {
        case .completed, .failed:
            return .finished
        case .recovering:
            return .reconnect
        case .replanning, .awaitingExternal, .attentionRequired:
            return .running
        }
    }

    /// Live session hub — only when signal exists (never invent reconnect).
    static func face(for session: LiveSessionSnapshot) -> ConversationExecutionFace {
        switch session.timing {
        case .finished: return .finished
        case .paused: return .paused
        case .running: return .running
        }
    }

    static func attention(for state: AtlasExecutionPresentationState) -> ConversationExecutionAttention? {
        switch state.kind {
        case .failed: return .failed
        case .recovering: return .recovering
        case .replanning: return .replanning
        case .awaitingExternal: return .awaiting
        case .attentionRequired: return .decision
        case .completed: return nil
        }
    }

    static func isFinished(_ bubble: ChatBubble) -> Bool {
        guard let state = bubble.executionPresentationState else {
            return !bubble.streaming && bubble.reconnectNotice == nil && bubble.agents.isEmpty
        }
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
        guard face(for: bubble) == .reconnect || bubble.showsReconnectSurface else { return false }
        if bubble.streaming && bubble.showsReconnectSurface { return false }
        return true
    }

    static func ribbonShowsSilenceWatchdog(_ bubble: ChatBubble) -> Bool {
        let face = face(for: bubble)
        return face == .running || face == .multiAgent || face == .paused
            || (face == .reconnect && bubble.streaming)
    }

    /// Strip: finished silences live chrome noise.
    static func stripShowsLiveChrome(_ bubble: ChatBubble) -> Bool {
        let face = face(for: bubble)
        return face != .finished && face != .quiet
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

    static func spokenAttention(_ attention: ConversationExecutionAttention) -> String {
        switch attention {
        case .awaiting: return "aguardando externo"
        case .recovering: return "recuperando"
        case .replanning: return "replanejando"
        case .failed: return "falhou"
        case .decision: return "decisão necessária"
        }
    }

    /// Timer honesty: missing ms → nil (caller shows “—” or silence), never 0:00.
    static func honestClock(ms: Int?) -> String? {
        guard let ms, ms >= 0 else { return nil }
        return AtlasTime.formatActiveDuration(milliseconds: ms)
    }
}
