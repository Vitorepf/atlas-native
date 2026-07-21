import AtlasCore
import SwiftUI

// IDLE-COMPRESS peel ExecutionStateCard spoken organ (canon §7 · same domain)

extension ExecutionStateCard {
    static func copyMentionsCanLeave(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        return text.contains("pode sair")
    }
}

extension ExecutionStateCard {
    var spokenFailureReason: String? {
        guard state.kind == .failed, let detail = state.detail else { return nil }
        return "motivo: \(detail)"
    }

    var failureReasonA11y: String? {
        guard state.kind == .failed, let detail = state.detail else { return nil }
        return "motivo da falha: \(detail)"
    }
}

extension ExecutionStateCard {
    var leaveScreenKicker: String? {
        guard state.kind == .awaitingExternal else { return nil }
        if Self.copyMentionsCanLeave(state.detail) || Self.copyMentionsCanLeave(state.title) {
            return nil
        }
        guard state.timer?.timing == .paused else { return nil }
        return "Você pode sair desta tela"
    }
}

extension ExecutionStateCard {
    var showsRetryFallback: Bool {
        state.kind == .failed
            && state.actions.isEmpty
            && retryableJobId != nil
    }
}

extension ExecutionStateCard {
    func spokenMetaParts(into parts: inout [String]) {
        if let kicker = leaveScreenKicker { parts.append(kicker) }
        if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
    }
}

extension ExecutionStateCard {
    func spokenReasonParts(into parts: inout [String]) {
        if let reason = spokenFailureReason {
            parts.append(reason)
        } else if let detail = state.detail {
            parts.append(detail)
        }
    }
}

extension ExecutionStateCard {
    func spokenDetailParts(into parts: inout [String]) {
        spokenReasonParts(into: &parts)
        spokenMetaParts(into: &parts)
    }
}

extension ExecutionStateCard {
    func spokenSummaryLead(into parts: inout [String]) {
        // WAVE-023: face vocabulary first (spoken ≡ visual product word).
        parts.append(ConversationExecutionPhase.primarySpoken(for: state))
        if let attention = presenceAttention, attention != .decision {
            parts.append(ConversationExecutionPhase.spokenAttention(attention))
        }
        if let kind = spokenKind { parts.append(kind) }
        parts.append(state.title)
    }
}

extension ExecutionStateCard {
    func spokenSummaryTail(into parts: inout [String]) {
        spokenDetailParts(into: &parts)
        spokenTimingParts(into: &parts)
    }
}

extension ExecutionStateCard {
    var spokenSummaryText: String {
        var parts: [String] = []
        spokenSummaryLead(into: &parts)
        spokenSummaryTail(into: &parts)
        return parts.joined(separator: ". ")
    }
}

extension ExecutionStateCard {
    func spokenDeadlineParts(into parts: inout [String]) {
        if let deadline = publishedExternalDeadline { parts.append("próxima mudança \(deadline)") }
        if let action = spokenActionFragment { parts.append(action) }
    }
}

extension ExecutionStateCard {
    func spokenTimingParts(into parts: inout [String]) {
        spokenTimerPart(into: &parts)
        spokenDeadlineParts(into: &parts)
    }
}

extension ExecutionStateCard {
    var spokenSummary: String { spokenSummaryText }
}

extension ExecutionStateCard {
    var spokenActionFragment: String? {
        if !state.actions.isEmpty {
            return "\(state.actions.count) ação\(state.actions.count == 1 ? "" : "ões") disponíveis"
        }
        if showsRetryFallback {
            return "retomar disponível"
        }
        return nil
    }
}

extension ExecutionStateCard {
    /// WAVE-052: spoken/tint from Judgment.
    var spokenKindWait: String? {
        switch state.kind {
        case .attentionRequired, .awaitingExternal:
            return ExecutionStateCardJudgment.spoken(for: state.kind)
        default: return nil
        }
    }

    var spokenKindAttention: String? {
        if let wait = spokenKindWait { return wait }
        switch state.kind {
        case .recovering, .replanning:
            return ExecutionStateCardJudgment.spoken(for: state.kind)
        default: return nil
        }
    }

    var spokenKindTerminal: String {
        ExecutionStateCardJudgment.spoken(for: state.kind)
    }

    var spokenKind: String? {
        ExecutionStateCardJudgment.spoken(for: state.kind)
    }

    var tintAttention: Color? {
        ExecutionStateCardJudgment.attentionTint(for: state.kind)
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var retryFallbackButton: some View {
        if showsRetryFallback, let retryableJobId {
            retryFallbackAction(retryableJobId)
        }
    }
}

