import AtlasCore
import SwiftUI

// Cycle 044 fuse → ExecutionStateCard.swift

/// Cena operacional do Fable 5: o estado chega pronto do ledger e só então a
/// conversa oferece uma ação. Não há botão, prazo ou risco criado pela casca.
struct ExecutionStateCard: View {
    let state: AtlasExecutionPresentationState
    let jobId: JobID?
    let onChoose: (JobID, String) -> Void
    var retryableJobId: JobID? = nil
    var onRetry: (JobID) -> Void = { _ in }
    var onSteer: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        stateCardChrome { stateCardStack }
    }
}

// Action buttons, style, choices, steer, retry. Cycle 020 fuse.

extension ExecutionStateCard {
    @ViewBuilder
    var actionButtons: some View {
        choiceActionButtons
        steerButton
    }

    @ViewBuilder
    var choiceActionButtons: some View {
        if effectiveChoiceJobId != nil, !state.actions.isEmpty {
            choiceButtonsStack
        } else {
            retryFallbackButton
        }
    }

    @ViewBuilder
    var choiceButtonsStack: some View {
        if let choiceJobId = effectiveChoiceJobId, !state.actions.isEmpty {
            HStack(spacing: 8) {
                ForEach(state.actions) { action in
                    choiceActionButton(action, choiceJobId: choiceJobId)
                }
            }
        }
    }

    func choiceActionButton(_ action: AtlasExecutionPresentationState.Action, choiceJobId: JobID) -> some View {
        Button {
            // Medium: server-declared execution choice is a governed commit.
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onChoose(choiceJobId, action.id)
        } label: {
            Text(action.title)
                .font(.system(.caption, weight: .semibold))
                .lineLimit(1)
                .padding(.horizontal, 11).padding(.vertical, 8)
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(ExecutionStateActionStyle(
            style: action.style,
            reduceMotion: reduceMotion
        ))
        .accessibilityIdentifier(A11yID.executionActionChoice(action.id))
        .accessibilityLabel(action.title)
        .accessibilityHint("ação declarada pelo servidor")
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(action.style == .primary || action.style == .destructive ? 9 : 0)
    }

    @ViewBuilder
    var retryFallbackButton: some View {
        if showsRetryFallback, let retryableJobId {
            retryFallbackAction(retryableJobId)
        }
    }

    @ViewBuilder
    func retryFallbackAction(_ jobId: JobID) -> some View {
        retryFallbackA11y(
            Button {
                // Medium: re-queue failed job is governed.
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                onRetry(jobId)
            } label: {
                retryFallbackLabel
            }
        )
    }

    func retryFallbackA11y<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(ExecutionStateActionStyle(
                style: .primary,
                reduceMotion: reduceMotion
            ))
            .accessibilityIdentifier(A11yID.executionRetry)
            .accessibilityLabel("retomar execução a partir do último checkpoint")
            .accessibilityHint("reenfileira o job que falhou")
            .accessibilityAddTraits(.isButton)
            .accessibilitySortPriority(9)
    }

    var retryFallbackLabel: some View {
        Text("Retomar")
            .font(.system(.caption, weight: .semibold))
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
    }

    @ViewBuilder
    var steerButton: some View {
        if onSteer != nil {
            steerActionButton
        }
    }

    @ViewBuilder
    var steerActionButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onSteer?()
        } label: {
            steerButtonLabel
        }
        .buttonStyle(ExecutionStateActionStyle(
            style: .secondary,
            reduceMotion: reduceMotion
        ))
        .accessibilityLabel("redirecionar esta execução")
        .accessibilityHint("abre instrução para o próximo checkpoint seguro")
        .accessibilityAddTraits(.isButton)
    }

    var steerButtonLabel: some View {
        Text("Redirecionar")
            .font(.system(.caption, weight: .semibold))
            .lineLimit(1)
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
    }
}

/// Estilo dos botões de ação do ExecutionStateCard.
struct ExecutionStateActionStyle: ButtonStyle {
    let style: AtlasExecutionPresentationState.ActionStyle
    var reduceMotion: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .background(Capsule().fill(background.opacity(configuration.isPressed ? 0.72 : 1)))
            .overlay(Capsule().stroke(border, lineWidth: 1))
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
            .animation(
                reduceMotion
                    ? nil
                    : (configuration.isPressed
                        ? .easeOut(duration: AtlasMotion.instinct)
                        : .spring(response: 0.25, dampingFraction: 0.82)),
                value: configuration.isPressed
            )
    }

    var border: Color {
        style == .destructive ? AtlasTheme.domOperacional.opacity(0.55) : AtlasTheme.separator
    }

    var background: Color {
        switch style {
        case .primary: return AtlasTheme.accent
        case .secondary: return AtlasTheme.surfaceHi
        case .destructive: return AtlasTheme.domOperacional.opacity(0.2)
        }
    }

    var foreground: Color {
        style == .primary ? AtlasTheme.bg : AtlasTheme.textPrimary
    }
}

// Awaiting/failed leave/retry predicates + spoken assembly. Cycle 020 fuse.

extension ExecutionStateCard {
    static func copyMentionsCanLeave(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        return text.contains("pode sair")
    }
}

extension ExecutionStateCard {
    /// Cena 13: o motivo falado vem do `detail` publicado pelo servidor.
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
    /// «Pode sair» só quando o contrato pausa o timer ou o servidor já publicou essa copy.
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
    func spokenTimerPart(into parts: inout [String]) {
        if let fragment = spokenTimerFragment { parts.append(fragment) }
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
    /// Prazo só na espera externa; o campo `deadline` do contrato não vale para outros kinds.
    var publishedExternalDeadline: String? {
        guard state.kind == .awaitingExternal else { return nil }
        return state.deadline
    }

    /// Job para ações declaradas: atenção usa `jobId`; falha usa `retryableJobId` real.
    var effectiveChoiceJobId: JobID? {
        if let jobId { return jobId }
        if state.kind == .failed { return retryableJobId }
        return nil
    }
}

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
            // Contain without fused label: choice/retry/steer buttons stay focusable.
            .accessibilityElement(children: .contain)
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

    /// Pure formatter — nonisolated so spoken helpers outside MainActor can call it.
    nonisolated static func clock(_ ms: Int) -> String {
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
