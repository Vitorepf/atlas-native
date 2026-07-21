import SwiftUI
import AtlasCore

// Presentation: chrome, header, meta, detail, icon, badge, timers, tint, stack. Cycle 020 fuse.

extension ExecutionStateCard {
    func stateCardChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.card)
                    .fill(AtlasTheme.surface.opacity(0.68))
                    .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).stroke(tint.opacity(0.42), lineWidth: 1))
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel(spokenSummary)
            .accessibilityIdentifier(A11yID.executionStateCard)
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var detailLine: some View {
        if let detail = state.detail {
            Text(detail)
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    static func shouldDisplay(state: AtlasExecutionPresentationState) -> Bool {
        if state.kind == .completed,
           state.actions.isEmpty,
           state.detail == nil,
           state.checkpoint == nil,
           state.deadline == nil {
            return false
        }
        return true
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var stateHeaderBadge: some View {
        if let badge = kindBadge {
            Text(badge)
                .font(AtlasFont.mono(10)).tracking(0.8)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    var stateHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: icon)
                .atlasSans(13, .semibold)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            Text(state.title)
                .font(.system(.footnote, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Spacer(minLength: 0)
            stateHeaderBadge
        }
    }
}

extension ExecutionStateCard {
    var iconWait: String? {
        switch state.kind {
        case .attentionRequired: return "exclamationmark.shield"
        case .awaitingExternal: return "hourglass"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var iconAttention: String? {
        if let wait = iconWait { return wait }
        switch state.kind {
        case .recovering: return "arrow.triangle.2.circlepath"
        case .replanning: return "arrow.triangle.branch"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var iconTerminal: String {
        switch state.kind {
        case .failed: return "xmark.octagon"
        case .completed: return "checkmark.seal"
        default: return iconAttention ?? "exclamationmark.shield"
        }
    }
}

extension ExecutionStateCard {
    var icon: String {
        iconAttention ?? iconTerminal
    }

    static func clock(_ ms: Int) -> String {
        AtlasTime.formatActiveDuration(milliseconds: ms)
    }
}

extension ExecutionStateCard {
    var kindBadgeWait: String? {
        switch state.kind {
        case .attentionRequired: return "PAUSADO"
        case .awaitingExternal: return "AGUARDANDO"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var kindBadgeAttention: String? {
        if let wait = kindBadgeWait { return wait }
        switch state.kind {
        case .recovering: return "RECONECTANDO"
        case .replanning: return "REPLANEJANDO"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    /// Selo 1:1 com `kind` — nunca copy inventada além do mapeamento canônico.
    var kindBadge: String? {
        switch state.kind {
        case .failed: return "FALHOU"
        case .completed: return nil
        default: return kindBadgeAttention
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder var metaKickerLines: some View {
        if let kicker = leaveScreenKicker {
            Text(kicker)
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
        if let checkpoint = state.checkpoint {
            Text("checkpoint · \(checkpoint)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder var metaLines: some View {
        metaKickerLines
        timerMetaLines
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var deadlineMetaLine: some View {
        if let deadline = publishedExternalDeadline {
            Text("Próxima mudança: \(deadline)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var frozenTimerLine: some View {
        if let frozen = frozenTimerText {
            Text(frozen)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var recoveringTimerLine: some View {
        if frozenTimerText == nil, let active = recoveringTimerText {
            Text(active)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var timerMetaLines: some View {
        frozenTimerLine
        recoveringTimerLine
        deadlineMetaLine
    }
}

extension ExecutionStateCard {
    var spokenKindWait: String? {
        switch state.kind {
        case .attentionRequired: return "execução pausada, aguardando decisão"
        case .awaitingExternal: return "aguardando sistema externo"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var spokenKindAttention: String? {
        if let wait = spokenKindWait { return wait }
        switch state.kind {
        case .recovering: return "reconectando"
        case .replanning: return "replanejando"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var spokenKindTerminal: String {
        switch state.kind {
        case .failed: return "execução falhou"
        case .completed: return "execução concluída"
        default: return spokenKindAttention ?? "execução"
        }
    }
}

extension ExecutionStateCard {
    var spokenKind: String? {
        spokenKindAttention ?? spokenKindTerminal
    }
}

extension ExecutionStateCard {
    var tintAttention: Color? {
        switch state.kind {
        case .attentionRequired: return AtlasTheme.accent
        case .awaitingExternal, .recovering: return AtlasTheme.textSecondary
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var tint: Color {
        if let attention = tintAttention { return attention }
        switch state.kind {
        case .failed: return AtlasTheme.domOperacional
        case .replanning, .completed: return AtlasTheme.domAutonomos
        default: return AtlasTheme.accent
        }
    }
}

extension ExecutionStateCard {
    var stateCardStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            stateHeader
            detailLine
            metaLines
            actionButtons
        }
    }
}

extension ExecutionStateCard {
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
}

extension ExecutionStateCard {
    var frozenTimerA11y: String? {
        guard let timer = state.timer, timer.timing == .paused else { return nil }
        switch state.kind {
        case .attentionRequired, .awaitingExternal:
            return "tempo ativo congelado em \(Self.clock(timer.elapsedActiveMilliseconds))"
        default:
            return nil
        }
    }
}

extension ExecutionStateCard {
    var recoveringTimerText: String? {
        guard state.kind == .recovering, let timer = state.timer else { return nil }
        return "ativo \(Self.clock(timer.elapsedActiveMilliseconds))"
    }

    var spokenTimerFragment: String? {
        frozenTimerA11y ?? recoveringTimerText
    }
}
