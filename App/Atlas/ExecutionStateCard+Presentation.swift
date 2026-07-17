import SwiftUI
import AtlasCore

// Selo, ícone, tint e resumo falado — peel de ExecutionStateCard (régua ~160).

extension ExecutionStateCard {
    var spokenSummary: String {
        var parts: [String] = []
        if let kind = spokenKind { parts.append(kind) }
        parts.append(state.title)
        if let detail = state.detail { parts.append(detail) }
        if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
        if let fragment = spokenTimerFragment { parts.append(fragment) }
        if let deadline = state.deadline { parts.append("próxima mudança \(deadline)") }
        if !state.actions.isEmpty {
            parts.append("\(state.actions.count) ação\(state.actions.count == 1 ? "" : "ões") disponíveis")
        }
        return parts.joined(separator: ". ")
    }

    var spokenKind: String? {
        switch state.kind {
        case .attentionRequired: return "execução pausada, aguardando decisão"
        case .awaitingExternal: return "aguardando sistema externo"
        case .recovering: return "reconectando"
        case .replanning: return "replanejando"
        case .failed: return "execução falhou"
        case .completed: return "execução concluída"
        }
    }

    /// Selo 1:1 com `kind` — nunca copy inventada além do mapeamento canônico.
    var kindBadge: String? {
        switch state.kind {
        case .attentionRequired: return "PAUSADO"
        case .awaitingExternal: return "AGUARDANDO"
        case .recovering: return "RECONECTANDO"
        case .replanning: return "REPLANEJANDO"
        case .failed: return "FALHOU"
        case .completed: return nil
        }
    }

    var tint: Color {
        switch state.kind {
        case .attentionRequired: return AtlasTheme.accent
        case .awaitingExternal, .recovering: return AtlasTheme.textSecondary
        case .failed: return AtlasTheme.domOperacional
        case .replanning, .completed: return AtlasTheme.domAutonomos
        }
    }

    var icon: String {
        switch state.kind {
        case .attentionRequired: return "exclamationmark.shield"
        case .awaitingExternal: return "hourglass"
        case .recovering: return "arrow.triangle.2.circlepath"
        case .replanning: return "arrow.triangle.branch"
        case .failed: return "xmark.octagon"
        case .completed: return "checkmark.seal"
        }
    }

    static func clock(_ ms: Int) -> String {
        AtlasTime.formatActiveDuration(milliseconds: ms)
    }

    /// Timer congelado (‖) — paridade Island/Lock para `.attentionRequired` e
    /// `.awaitingExternal` quando o servidor publica `timing: paused`.
    var frozenTimerText: String? {
        guard let timer = state.timer, timer.timing == .paused else { return nil }
        switch state.kind {
        case .attentionRequired, .awaitingExternal:
            return "‖ \(Self.clock(timer.elapsedActiveMilliseconds))"
        default:
            return nil
        }
    }

    var frozenTimerA11y: String? {
        guard let timer = state.timer, timer.timing == .paused else { return nil }
        switch state.kind {
        case .attentionRequired, .awaitingExternal:
            return "tempo ativo congelado em \(Self.clock(timer.elapsedActiveMilliseconds))"
        default:
            return nil
        }
    }

    var recoveringTimerText: String? {
        guard state.kind == .recovering, let timer = state.timer else { return nil }
        return "ativo \(Self.clock(timer.elapsedActiveMilliseconds))"
    }

    var spokenTimerFragment: String? {
        frozenTimerA11y ?? recoveringTimerText
    }
}
