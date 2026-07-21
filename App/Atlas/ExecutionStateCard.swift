import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: ExecutionStateCard peels fused (Judgment stays separate)

// MARK: - Host

extension ExecutionStateCard {
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
}

extension ExecutionStateCard {
    func spokenTimerPart(into parts: inout [String]) {
        if let fragment = spokenTimerFragment { parts.append(fragment) }
    }
}

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
        // WAVE-027: primary = face spoken; server title = detail only.
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: icon)
                .atlasSans(13, .semibold)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(ConversationExecutionPhase.primarySpoken(for: state))
                    .font(AtlasFont.mono(11, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                if !state.title.isEmpty {
                    Text(state.title)
                        .font(AtlasFont.serifItalic(12))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(2)
                        .accessibilityHidden(true)
                }
            }
            Spacer(minLength: 0)
            Text(
                (presenceAttention == .decision
                    ? ConversationDecisionJudgment.productWord
                    : ConversationExecutionPhase.primaryProduct(presenceFace)
                ).uppercased()
            )
            .font(AtlasFont.mono(9))
            .tracking(0.6)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
            stateHeaderBadge
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
    /// WAVE-052: completed stays badge-silent (parity); others from Judgment.
    var kindBadge: String? {
        switch state.kind {
        case .completed: return nil
        default: return ExecutionStateCardJudgment.badge(for: state.kind)
        }
    }
}

extension ExecutionStateCard {
    var tint: Color {
        ExecutionStateCardJudgment.tint(for: state.kind)
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

struct ExecutionStateCard: View {
    let state: AtlasExecutionPresentationState
    let jobId: JobID?
    let onChoose: (JobID, String) -> Void
    var retryableJobId: JobID? = nil
    var onRetry: (JobID) -> Void = { _ in }
    var onSteer: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    /// WAVE-023: exclusive face + attention overlay (not parallel dialects).
    var presenceFace: ConversationExecutionFace {
        ConversationExecutionPhase.face(for: state)
    }

    var presenceAttention: ConversationExecutionAttention? {
        ConversationExecutionPhase.attention(for: state)
    }

    var body: some View {
        stateCardChrome { stateCardStack }
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var actionButtons: some View {
        choiceActionButtons
        steerButton
    }
}
// MARK: - Body

// MARK: - Host

extension ExecutionStateCard {
    func choiceActionButton(_ action: AtlasExecutionPresentationState.Action, choiceJobId: JobID) -> some View {
        Button { onChoose(choiceJobId, action.id) } label: {
            Text(action.title)
                .font(.system(.caption, weight: .semibold))
                .lineLimit(1)
                .padding(.horizontal, 11).padding(.vertical, 8)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ExecutionStateActionStyle(
            style: action.style,
            reduceMotion: reduceMotion
        ))
        .accessibilityIdentifier(A11yID.executionActionChoice(action.id))
        .accessibilityLabel(action.title)
        .accessibilityHint("ação declarada pelo servidor")
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var choiceActionButtons: some View {
        if effectiveChoiceJobId != nil, !state.actions.isEmpty {
            choiceButtonsStack
        } else {
            retryFallbackButton
        }
    }
}


// MARK: - Helpers

extension ExecutionStateCard {
    var publishedExternalDeadline: String? {
        guard state.kind == .awaitingExternal else { return nil }
        return state.deadline
    }

    var effectiveChoiceJobId: JobID? {
        if let jobId { return jobId }
        if state.kind == .failed { return retryableJobId }
        return nil
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var detailLine: some View {
        if let detail = state.detail {
            Text(detail)
                .font(AtlasFont.serifItalic(14))
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
    /// WAVE-052: chrome maps owned by Judgment.
    var iconWait: String? {
        switch state.kind {
        case .attentionRequired, .awaitingExternal:
            return ExecutionStateCardJudgment.iconName(for: state.kind)
        default: return nil
        }
    }

    var iconAttention: String? {
        if let wait = iconWait { return wait }
        switch state.kind {
        case .recovering, .replanning:
            return ExecutionStateCardJudgment.iconName(for: state.kind)
        default: return nil
        }
    }

    var iconTerminal: String {
        ExecutionStateCardJudgment.iconName(for: state.kind)
    }

    var kindBadgeWait: String? {
        switch state.kind {
        case .attentionRequired, .awaitingExternal:
            return ExecutionStateCardJudgment.badge(for: state.kind)
        default: return nil
        }
    }

    var kindBadgeAttention: String? {
        if let wait = kindBadgeWait { return wait }
        switch state.kind {
        case .recovering, .replanning:
            return ExecutionStateCardJudgment.badge(for: state.kind)
        default: return nil
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
// MARK: - Spoken

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
// MARK: - Spoken body

extension ExecutionStateCard {
    func retryFallbackA11y<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(ExecutionStateActionStyle(
                style: .primary,
                reduceMotion: reduceMotion
            ))
            .accessibilityIdentifier(A11yID.executionRetry)
            .accessibilityLabel(ExecutionStateCardJudgment.retryLabel)
            .accessibilityHint(ExecutionStateCardJudgment.retryHint)
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    func retryFallbackAction(_ jobId: JobID) -> some View {
        retryFallbackA11y(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry(jobId)
            } label: {
                retryFallbackLabel
            }
        )
    }
}

extension ExecutionStateCard {
    var retryFallbackLabel: some View {
        Text("Retomar")
            .font(AtlasFont.mono(10, .semibold))
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity)
    }
}

extension ExecutionStateCard {
    var steerButtonLabel: some View {
        Text("Redirecionar")
            .font(.system(.caption, weight: .semibold))
            .lineLimit(1)
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity)
    }
}

extension ExecutionStateCard {
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
        .accessibilityLabel(ConversationLiveStripJudgment.spokenSteer())
        .accessibilityHint(ConversationLiveStripJudgment.spokenSteerHint())
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var steerButton: some View {
        if onSteer != nil {
            steerActionButton
        }
    }
}

extension ExecutionStateCard {
    var frozenTimerText: String? {
        guard let timer = state.timer, timer.timing == .paused else { return nil }
        guard ExecutionStateCardJudgment.freezesTimer(for: state.kind) else { return nil }
        return "‖ \(Self.clock(timer.elapsedActiveMilliseconds))"
    }
}

extension ExecutionStateCard {
    var frozenTimerA11y: String? {
        guard let timer = state.timer, timer.timing == .paused else { return nil }
        guard ExecutionStateCardJudgment.freezesTimer(for: state.kind) else { return nil }
        return "tempo ativo congelado em \(Self.clock(timer.elapsedActiveMilliseconds))"
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
// MARK: - Action style

extension ExecutionStateActionStyle {
    var border: Color {
        style == .destructive ? AtlasTheme.domOperacional.opacity(0.55) : AtlasTheme.separator
    }
}

extension ExecutionStateActionStyle {
    var background: Color {
        switch style {
        case .primary: return AtlasTheme.accent
        case .secondary: return AtlasTheme.surfaceHi
        case .destructive: return AtlasTheme.domOperacional.opacity(0.2)
        }
    }
}

extension ExecutionStateActionStyle {
    var foreground: Color {
        style == .primary ? AtlasTheme.bg : AtlasTheme.textPrimary
    }
}

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
                reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct),
                value: configuration.isPressed
            )
    }
}

// MARK: - Judgment

// MARK: - Judgment

/// Pure StateCard chrome grammar for `AtlasExecutionPresentationState.Kind`
/// (WAVE-052). One map: icon · badge · spoken · tint · freezesTimer.
enum ExecutionStateCardJudgment {

    // MARK: Icon

    static func iconName(for kind: AtlasExecutionPresentationState.Kind) -> String {
        switch kind {
        case .attentionRequired: return "exclamationmark.shield"
        case .awaitingExternal: return "hourglass"
        case .recovering: return "arrow.triangle.2.circlepath"
        case .replanning: return "arrow.triangle.branch"
        case .failed: return "xmark.octagon"
        case .completed: return "checkmark.seal"
        }
    }

    // MARK: Badge (uppercase product strip)

    static func badge(for kind: AtlasExecutionPresentationState.Kind) -> String? {
        switch kind {
        case .attentionRequired: return "PAUSADO"
        case .awaitingExternal: return "AGUARDANDO"
        case .recovering: return "RECONECTANDO"
        case .replanning: return "REPLANEJANDO"
        case .failed: return "FALHOU"
        case .completed: return "CONCLUÍDO"
        }
    }

    // MARK: Spoken

    static func spoken(for kind: AtlasExecutionPresentationState.Kind) -> String {
        switch kind {
        case .attentionRequired:
            return "execução pausada, aguardando decisão"
        case .awaitingExternal:
            return "aguardando sistema externo"
        case .recovering:
            return "reconectando"
        case .replanning:
            return "replanejando"
        case .failed:
            return "execução falhou"
        case .completed:
            return "execução concluída"
        }
    }

    // MARK: Tint

    static func tint(for kind: AtlasExecutionPresentationState.Kind) -> Color {
        switch kind {
        case .attentionRequired: return AtlasTheme.accent
        case .awaitingExternal, .recovering: return AtlasTheme.textSecondary
        case .replanning: return AtlasTheme.accent
        case .failed: return AtlasTheme.domOperacional
        case .completed: return AtlasTheme.domAutonomos
        }
    }

    /// Optional attention overlay tint (nil = use default surface stroke).
    static func attentionTint(for kind: AtlasExecutionPresentationState.Kind) -> Color? {
        switch kind {
        case .attentionRequired: return AtlasTheme.accent
        case .awaitingExternal, .recovering: return AtlasTheme.textSecondary
        case .failed: return AtlasTheme.domOperacional
        case .replanning, .completed: return nil
        }
    }

    // MARK: Timer freeze

    /// Paused timer chrome only for human/external wait faces.
    static func freezesTimer(for kind: AtlasExecutionPresentationState.Kind) -> Bool {
        switch kind {
        case .attentionRequired, .awaitingExternal: return true
        case .recovering, .replanning, .failed, .completed: return false
        }
    }

    /// Provider-safe product word (wire Kind raw) — pack ≡ chrome vocabulary.
    static func productWord(for kind: AtlasExecutionPresentationState.Kind) -> String {
        kind.rawValue
    }

    // MARK: Pack (WAVE-180)

    /// Mid-thread pack for StateCard kind — never invents presentation state.
    static func packFacts(
        state: AtlasExecutionPresentationState?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        guard let state else {
            absences.append("execution presentation state não publicado neste recorte")
            return (facts, absences)
        }
        let kind = state.kind
        facts.append("state_card_kind: \(productWord(for: kind))")
        facts.append(
            "state_card_freezes_timer: \(freezesTimer(for: kind) ? "yes" : "no")"
        )
        if let badge = badge(for: kind) {
            facts.append("state_card_badge: \(badge)")
        }
        if !state.title.isEmpty {
            facts.append("state_card_title: \(state.title)")
        } else {
            absences.append("presentation state sem title publicado")
        }
        // Attention overlay product (Phase grammar) when mappable.
        if let attention = ConversationExecutionPhase.attention(for: state) {
            facts.append("state_card_attention: \(attention.rawValue)")
        }
        return (facts, absences)
    }

    static let retryLabel = "retomar execução a partir do último checkpoint"
    static let retryHint = "reenfileira o job que falhou"
}
