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
            .accessibilityLabel(ExecutionStateCardJudgment.spokenRetry)
            .accessibilityHint(ExecutionStateCardJudgment.spokenRetryHint)
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
        .accessibilityLabel(ConversationLiveStripJudgment.spokenSteer)
        .accessibilityHint(ConversationLiveStripJudgment.spokenSteerHint)
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

    static let spokenRetry = "retomar execução a partir do último checkpoint"
    static let spokenRetryHint = "reenfileira o job que falhou"
}

// MARK: - ExecutionProof

// MARK: - Host

// MARK: - Types / Inputs

struct ExecutionProof: View {
    let bubble: ChatBubble
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var open = false
    @State var replayIndex = 0

    // MARK: Body

    var body: some View {
        proofChrome { proofStack }
    }
}

extension ExecutionProof {
    func activityRowCopy(_ act: AtlasAgentActivity) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(act.title)
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
            if let d = act.detail, !d.isEmpty {
                Text(d).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(2).truncationMode(.middle)
            }
        }
    }
}

extension ExecutionProof {
    func activityRowCell(index: Int, act: AtlasAgentActivity) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: activityIcon(act.kind))
                .atlasSans(11).foregroundStyle(AtlasTheme.accent.opacity(0.8))
                .frame(width: 15)
                .accessibilityHidden(true)
            activityRowCopy(act)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "passo \(index + 1) de \(bubble.activities.count), \(activitySpoken(act))"
        )
    }
}

extension ExecutionProof {
    @ViewBuilder
    var activityRows: some View {
        if !bubble.activities.isEmpty {
            ForEach(Array(bubble.activities.enumerated()), id: \.element.id) { index, act in
                activityRowCell(index: index, act: act)
            }
        }
    }
}

extension ExecutionProof {
    @ViewBuilder
    var artifactsBlock: some View {
        if !artifactItems.isEmpty, let traceId = bubble.traceId {
            artifactsButtonA11y(
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onOpenArtifacts(traceId)
                } label: {
                    artifactsButtonLabel(count: artifactItems.count)
                },
                count: artifactItems.count
            )
        }
    }
}

extension ExecutionProof {
    func artifactsButtonA11y<Content: View>(_ content: Content, count: Int) -> some View {
        content
            .buttonStyle(.plain)
            .accessibilityIdentifier(A11yID.artifactsRow)
            .accessibilityLabel(ExecutionProofJudgment.spokenArtifactsCTA(count: count))
            .accessibilityHint(ExecutionProofJudgment.spokenArtifactsHint)
    }
}

extension ExecutionProof {
    var artifactsChevron: some View {
        Image(systemName: "chevron.right")
            .atlasSans(10, .semibold)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension ExecutionProof {
    func artifactsButtonLabel(count: Int) -> some View {
        HStack(spacing: 6) {
            artifactsButtonLead(count: count)
            artifactsChevron
        }
        .contentShape(Rectangle())
    }
}

extension ExecutionProof {
    func artifactsButtonLead(count: Int) -> some View {
        HStack(spacing: 6) {
            Text("⎘")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.accent.opacity(0.8))
                .frame(width: 15)
                .accessibilityHidden(true)
            Text("ARTEFATOS (\(count))")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
            Spacer()
        }
    }
}

// MARK: - Body

// MARK: - Expanded content

extension ExecutionProof {
    @ViewBuilder
    var expandedProofContent: some View {
        VStack(alignment: .leading, spacing: 7) {
            replayScrubber
            activityRows
            decisionBlock
            qualityBlock
            artifactsBlock
        }
        .padding(.top, 8)
        .padding(.leading, 4)
        .transition(reduceMotion ? .identity : .opacity)
        .onChange(of: bubble.activities.count) {
            replayIndex = min(replayIndex, max(0, timestampedActivities.count - 1))
        }
    }
}

// MARK: - Decision / quality sections

extension ExecutionProof {
    @ViewBuilder
    var decisionBlock: some View {
        if let d = bubble.decisionSummary, Self.hasDecisionSurface(d) {
            Divider().overlay(AtlasTheme.separatorSoft).accessibilityHidden(true)
            decisionSummaryRow(d)
            decisionReason(d)
        }
    }

    @ViewBuilder
    func decisionSummaryRow(_ d: AtlasDecisionSummary) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.triangle.branch")
                .atlasSans(11).foregroundStyle(AtlasTheme.accent.opacity(0.8)).frame(width: 15)
                .accessibilityHidden(true)
            Text(decideLine(d))
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(decisionSpoken(d))
    }

    @ViewBuilder
    func decisionReason(_ d: AtlasDecisionSummary) -> some View {
        if let r = d.reason, !r.isEmpty {
            Text("\"\(r)\"")
                .font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                .padding(.leading, 23)
                .accessibilityLabel(ExecutionProofJudgment.spokenReason(r))
        }
    }

    @ViewBuilder
    var qualityBlock: some View {
        if let q = bubble.qualitySummary {
            HStack(spacing: 6) {
                Image(systemName: "seal")
                    .atlasSans(11).foregroundStyle(qualityColor(q)).frame(width: 15)
                    .accessibilityHidden(true)
                Text(qualityLine(q))
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
            }
            .accessibilityLabel(qualitySpoken(q))
        }
    }

    func qualityColor(_ q: AtlasQualitySummary) -> Color {
        q.status.lowercased().contains("pass") || q.score >= 0.7
            ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional
    }
}

// MARK: - Face / summary / spoken bridges

extension ExecutionProof {
    var timestampedActivities: [(activity: AtlasAgentActivity, date: Date)] {
        bubble.activities.compactMap { activity in
            guard let date = AtlasTime.date(activity.occurredAt) else { return nil }
            return (activity, date)
        }
    }

    var proofFace: ExecutionProofFace {
        ExecutionProofJudgment.face(bubble: bubble, artifactItems: rankedArtifactItems)
    }

    /// Kind-attention artifacts (shared with ArtifactJudgment).
    var rankedArtifactItems: [AtlasTraceArtifacts.Item] {
        ExecutionProofJudgment.rankedArtifacts(artifactItems)
    }

    var summaryLine: String {
        ExecutionProofJudgment.summaryLine(
            bubble: bubble,
            artifactItems: rankedArtifactItems,
            humanDuration: humanDuration
        )
    }

    func activitySpoken(_ act: AtlasAgentActivity) -> String {
        ExecutionProofJudgment.activitySpoken(act)
    }

    func qualityLineFlags(_ q: AtlasQualitySummary, base: String) -> String {
        ExecutionProofJudgment.qualityLineFlags(q, base: base)
    }

    func qualityLine(_ q: AtlasQualitySummary) -> String {
        ExecutionProofJudgment.qualityLine(q)
    }

    func qualitySpoken(_ q: AtlasQualitySummary) -> String {
        ExecutionProofJudgment.qualitySpoken(q)
    }
}

// MARK: - Replay scrubber

extension ExecutionProof {
    @ViewBuilder
    var replayScrubber: some View {
        let stamped = timestampedActivities
        if stamped.count >= 2 {
            let index = min(replayIndex, stamped.count - 1)
            let selected = stamped[index]
            replayScrubberChrome(index: index, total: stamped.count, selected: selected)
        } else if !bubble.activities.isEmpty {
            Text(ExecutionProofJudgment.spokenReplayUnavailable)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel(ExecutionProofJudgment.replayUnavailableSpoken)
        }
    }

    func replayScrubberChrome(
        index: Int,
        total: Int,
        selected: (activity: AtlasAgentActivity, date: Date)
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            replayScrubberHeader(index: index, total: total, selected: selected)
            replayControls(stampedCount: total)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.bgRecessed))
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
        .accessibilityIdentifier(A11yID.executionReplayScrubber)
    }

    func replayScrubberHeader(
        index: Int,
        total: Int,
        selected: (activity: AtlasAgentActivity, date: Date)
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            replayScrubberTitle(index: index, total: total)
            replayScrubberMeta(selected: selected)
        }
    }

    func replayScrubberTitle(index: Int, total: Int) -> some View {
        HStack {
            Text("REPLAY")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            Spacer()
            Text("\(index + 1)/\(total)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
    }

    func replayScrubberMeta(selected: (activity: AtlasAgentActivity, date: Date)) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(selected.activity.title)
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
                .accessibilityHidden(true)
            Text(selected.activity.occurredAt ?? "")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    func replayControls(stampedCount: Int) -> some View {
        if reduceMotion {
            replayStepperControl(stampedCount: stampedCount)
        } else {
            replaySliderControl(stampedCount: stampedCount)
        }
    }

    func replaySliderControl(stampedCount: Int) -> some View {
        Slider(value: Binding(
            get: { Double(replayIndex) },
            set: { replayIndex = min(max(0, Int($0.rounded())), stampedCount - 1) }
        ), in: 0...Double(stampedCount - 1), step: 1)
        .tint(AtlasTheme.accent)
        .accessibilityLabel(ExecutionProofJudgment.spokenReplayScrubber)
        .accessibilityValue(
            ExecutionProofJudgment.spokenReplayValue(
                index: replayIndex, total: stampedCount
            )
        )
    }

    func replayStepperControl(stampedCount: Int) -> some View {
        Stepper("passo \(min(replayIndex, stampedCount - 1) + 1)", value: Binding(
            get: { replayIndex },
            set: { replayIndex = min(max(0, $0), stampedCount - 1) }
        ), in: 0...(stampedCount - 1))
        .labelsHidden()
        .accessibilityLabel(
            ExecutionProofJudgment.spokenReplayStep(
                index: replayIndex, total: stampedCount
            )
        )
    }
}

// MARK: - Chrome

// MARK: - Chrome / gates

extension ExecutionProof {
    func proofChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.vertical, 8).padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface.opacity(0.35))
                    .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            )
    }
}

extension ExecutionProof {
    /// WAVE-042: gate owned by Judgment.
    static func hasDecisionSurface(_ d: AtlasDecisionSummary) -> Bool {
        ExecutionProofJudgment.hasDecisionSurface(d)
    }
}

extension ExecutionProof {
    var collapsedHeader: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : AtlasMotion.editorial) { open.toggle() }
        } label: {
            collapsedHeaderLabel
        }
        .buttonStyle(.plain)
        .accessibilityLabel(spokenCollapsed(expanded: open))
        .accessibilityHint(open ? "toque para fechar a prova" : "toque para expandir a prova")
        .accessibilityIdentifier(A11yID.executionProof)
    }
}

extension ExecutionProof {
    var collapsedHeaderLabel: some View {
        HStack(spacing: 10) {
            Circle().fill(AtlasTheme.accent).frame(width: 10, height: 10)
                .accessibilityHidden(true)
            collapsedHeaderSummary
            Spacer(minLength: 0)
            Text(open ? "Fechar" : "Abrir")
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
    }
}

extension ExecutionProof {
    @ViewBuilder
    var collapsedHeaderSummary: some View {
        VStack(alignment: .leading, spacing: 1) {
            // WAVE-042: exclusive face kicker (not always "Obra concluída").
            Text(proofFace.kicker)
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if !summaryLine.isEmpty {
                Text(summaryLine)
                    .font(.system(.caption)).foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension ExecutionProof {
    func decideLine(_ d: AtlasDecisionSummary) -> String {
        var out = "atlas decide"
        if let m = d.routeMode { out += " · \(m)" }
        if let p = d.selectedProvider { out += " · \(p)" }
        if let c = d.confidenceScore { out += " · conf \(String(format: "%.2f", c))" }
        if d.wasOverridden { out += " · override" }
        return out
    }
}

extension ExecutionProof {
    func decisionSpokenRoute(_ d: AtlasDecisionSummary) -> [String] {
        var parts = ["decisão do atlas"]
        if let m = d.routeMode { parts.append("modo \(m)") }
        if let p = d.selectedProvider { parts.append("provedor \(p)") }
        return parts
    }
}

extension ExecutionProof {
    func decisionSpoken(_ d: AtlasDecisionSummary) -> String {
        var parts = decisionSpokenRoute(d)
        if let c = d.confidenceScore { parts.append("confiança \(String(format: "%.2f", c))") }
        if d.wasOverridden { parts.append("substituída manualmente") }
        if let r = d.reason, !r.isEmpty { parts.append("motivo \(r)") }
        return parts.joined(separator: ", ")
    }
}

extension ExecutionProof {
    var spokenCollapsed: String {
        spokenCollapsed(expanded: false)
    }

    func spokenCollapsed(expanded: Bool) -> String {
        ExecutionProofJudgment.spokenCollapsed(
            bubble: bubble,
            artifactItems: rankedArtifactItems,
            expanded: expanded,
            humanDuration: humanDuration
        )
    }
}

extension ExecutionProof {
    static func shouldDisplay(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> Bool {
        ExecutionProofJudgment.shouldDisplay(
            bubble: bubble,
            artifactItems: artifactItems
        )
    }
}

extension ExecutionProof {
    var proofStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            collapsedHeader
            if open {
                expandedProofContent
            }
        }
    }
}

// MARK: - Ribbon

struct ExecutionRibbon: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void

    private var face: ConversationExecutionFace {
        ConversationExecutionPhase.face(for: bubble)
    }

    var body: some View {
        executionRibbonStack
            .padding(.vertical, 10).padding(.horizontal, 14)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control, fillOpacity: 0.5)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ConversationExecutionPhase.spokenFace(face))
    }

    var executionRibbonStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            reconnectBannerStack
            if face != .finished && face != .quiet {
                activitiesTimelineBlock
                agentLanes
                decideStrategyLine
            }
        }
    }

    @ViewBuilder
    var reconnectBannerStack: some View {
        // WAVE-012 + WAVE-022: dual-surface primary is strip; ribbon silence when streaming.
        if ConversationExecutionPhase.ribbonShowsReconnectBanner(bubble) {
            ReconnectBanner(bubble: bubble, reduceMotion: reduceMotion)
        }
        if ConversationExecutionPhase.ribbonShowsSilenceWatchdog(bubble) {
            SilenceWatchdog(bubble: bubble, reduceMotion: reduceMotion)
        }
    }

    @ViewBuilder
    var activitiesTimelineBlock: some View {
        if !bubble.activities.isEmpty {
            LiveTimeline(activities: bubble.activities, reduceMotion: reduceMotion)
        }
    }

    @ViewBuilder
    var agentLanes: some View {
        // WAVE-049: attention-ranked lanes (failed/awaiting first).
        let ranked = ConversationAgentLanesJudgment.rank(bubble.agents)
        let lanesFace = ConversationAgentLanesJudgment.face(from: bubble.agents)
        if !ranked.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                if let kicker = lanesFace.kicker {
                    Text(kicker)
                        .font(AtlasFont.mono(10))
                        .tracking(1.1)
                        .foregroundStyle(
                            lanesFace.productWord == "attention"
                                ? AtlasTheme.domOperacional
                                : AtlasTheme.textTertiary
                        )
                        .accessibilityLabel(lanesFace.spokenFace)
                        .accessibilityIdentifier(A11yID.executionAgentLanes)
                }
                ForEach(ranked) { AgentRow(agent: $0, compactLane: ranked.count >= 2) }
            }.padding(.leading, 24)
        }
    }

    @ViewBuilder
    var decideStrategyLine: some View {
        if let strat = bubble.decideStrategy {
            Text("atlas decide · \(strat)" + (bubble.decideStage.map { " → \($0)" } ?? ""))
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).padding(.leading, 24)
        }
    }
}

// MARK: - ExecutionProofJudgment

// MARK: - Types

/// Exclusive finished-turn proof face (WAVE-042).
enum ExecutionProofFace: Equatable {
    case empty
    case steps(Int)
    case decision
    case quality(score: Double, status: String)
    case evidence(Int)
    /// Multiple organs present — lead by strongest signal.
    case compound(lead: String, parts: [String])

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .steps: return "steps"
        case .decision: return "decision"
        case .quality: return "quality"
        case .evidence: return "evidence"
        case .compound: return "compound"
        }
    }

    /// Collapsed header kicker — never always "Obra concluída".
    var kicker: String {
        switch self {
        case .empty: return "Prova"
        case .steps: return "Obra com passos"
        case .decision: return "Decisão do atlas"
        case .quality: return "Qualidade da obra"
        case .evidence: return "Evidência publicada"
        case .compound(let lead, _): return lead
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem prova publicada"
        case .steps(let n):
            return n == 1 ? "prova com 1 passo" : "prova com \(n) passos"
        case .decision:
            return "prova com decisão do atlas"
        case .quality(let score, let status):
            return "prova de qualidade \(String(format: "%.1f", score)), status \(status)"
        case .evidence(let n):
            return n == 1 ? "prova com 1 artefato" : "prova com \(n) artefatos"
        case .compound(_, let parts):
            return "prova composta, " + parts.joined(separator: ", ")
        }
    }
}

// MARK: - Judgment

/// Pure execution proof grammar — face · gates · summary · pack · spoken.
enum ExecutionProofJudgment {

    static func hasDecisionSurface(_ d: AtlasDecisionSummary) -> Bool {
        d.selectedProvider != nil
            || d.selectedModel != nil
            || d.reason != nil
            || d.confidenceScore != nil
            || d.riskLevel != nil
            || d.routeMode != nil
            || d.wasOverridden
    }

    static func shouldDisplay(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> Bool {
        !bubble.activities.isEmpty
            || bubble.decisionSummary.map(hasDecisionSurface) == true
            || bubble.qualitySummary != nil
            || (!artifactItems.isEmpty && bubble.traceId != nil)
    }

    static func face(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> ExecutionProofFace {
        guard shouldDisplay(bubble: bubble, artifactItems: artifactItems) else {
            return .empty
        }

        var parts: [String] = []
        var lead = "Prova da obra"

        let steps = bubble.activities.count
        if steps > 0 {
            parts.append(steps == 1 ? "1 passo" : "\(steps) passos")
            lead = "Obra com passos"
        }
        if let d = bubble.decisionSummary, hasDecisionSurface(d) {
            parts.append("decisão")
            lead = "Decisão do atlas"
        }
        if let q = bubble.qualitySummary {
            parts.append("quality \(String(format: "%.1f", q.score))")
            lead = "Qualidade da obra"
        }
        if !artifactItems.isEmpty {
            parts.append(artifactItems.count == 1 ? "1 artefato" : "\(artifactItems.count) artefatos")
            if steps == 0, bubble.decisionSummary.map(hasDecisionSurface) != true,
               bubble.qualitySummary == nil {
                lead = "Evidência publicada"
            }
        }

        if parts.count >= 2 {
            return .compound(lead: lead, parts: parts)
        }
        if steps > 0 { return .steps(steps) }
        if let d = bubble.decisionSummary, hasDecisionSurface(d) { return .decision }
        if let q = bubble.qualitySummary {
            return .quality(score: q.score, status: q.status)
        }
        if !artifactItems.isEmpty { return .evidence(artifactItems.count) }
        return .empty
    }

    static func summaryLine(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = [],
        humanDuration: (Int) -> String
    ) -> String {
        var parts: [String] = []
        if !bubble.activities.isEmpty {
            parts.append("\(bubble.activities.count) passos")
        }
        if let ms = bubble.elapsedMs, ms > 0 {
            parts.append(humanDuration(ms))
        }
        if let q = bubble.qualitySummary {
            parts.append("quality \(String(format: "%.1f", q.score))")
        }
        if !artifactItems.isEmpty {
            parts.append("\(artifactItems.count) artefatos")
        }
        if let d = bubble.decisionSummary, hasDecisionSurface(d) {
            if let mode = d.routeMode { parts.append(mode) }
            else { parts.append("decisão") }
        }
        return parts.joined(separator: " · ")
    }

    static func rankedArtifacts(
        _ items: [AtlasTraceArtifacts.Item]
    ) -> [AtlasTraceArtifacts.Item] {
        ArtifactJudgment.rankItems(items)
    }

    static func spokenCollapsed(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item],
        expanded: Bool,
        humanDuration: (Int) -> String
    ) -> String {
        let face = face(bubble: bubble, artifactItems: artifactItems)
        var parts = [
            "prova da execução",
            expanded ? "expandida" : "recolhida",
            face.spokenFace
        ]
        if let ms = bubble.elapsedMs, ms > 0 {
            parts.append(humanDuration(ms))
        }
        return parts.joined(separator: ", ")
    }

    static func packFacts(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(bubble: bubble, artifactItems: artifactItems)
        facts.append("proof_face: \(face.productWord)")
        if !shouldDisplay(bubble: bubble, artifactItems: artifactItems) {
            absences.append("nenhuma prova publicada neste turno")
            return (facts, absences)
        }
        if !bubble.activities.isEmpty {
            facts.append("steps: \(bubble.activities.count)")
        } else {
            absences.append("sem passos de atividade")
        }
        if let d = bubble.decisionSummary, hasDecisionSurface(d) {
            if let p = d.selectedProvider { facts.append("decision_provider: \(p)") }
            if let m = d.routeMode { facts.append("decision_mode: \(m)") }
            if let c = d.confidenceScore {
                facts.append("decision_confidence: \(String(format: "%.2f", c))")
            }
        } else {
            absences.append("sem decisão de atlas publicada")
        }
        if let q = bubble.qualitySummary {
            let quality = qualityPackFacts(q)
            facts.append(contentsOf: quality.facts)
            absences.append(contentsOf: quality.absences)
        } else {
            absences.append("sem quality summary")
        }
        if artifactItems.isEmpty {
            absences.append("sem artefatos na prova")
        } else {
            facts.append("artifacts: \(artifactItems.count)")
            for item in rankedArtifacts(artifactItems).prefix(4) {
                facts.append("artifact: \(item.kind.rawValue) · \(item.name)")
            }
        }
        return (facts, absences)
    }


    // MARK: - Chrome spoken
    // MARK: - WAVE-082 quality · activity · replay absence

    static func qualityLineFlags(_ q: AtlasQualitySummary, base: String) -> String {
        var out = base
        if q.flagCount > 0 { out += " · \(q.flagCount) alertas" }
        if q.actionCount > 0 { out += " · \(q.actionCount) ações" }
        return out
    }

    static func qualityLine(_ q: AtlasQualitySummary) -> String {
        let base = "quality \(String(format: "%.1f", q.score)) · \(q.status)"
        return qualityLineFlags(q, base: base)
    }

    static func qualitySpoken(_ q: AtlasQualitySummary) -> String {
        var parts = ["qualidade \(String(format: "%.1f", q.score)), status \(q.status)"]
        if q.flagCount > 0 { parts.append("\(q.flagCount) alertas") }
        if q.actionCount > 0 { parts.append("\(q.actionCount) ações de correção") }
        return parts.joined(separator: ", ")
    }

    static func activitySpoken(_ act: AtlasAgentActivity) -> String {
        var parts = [act.title]
        if let d = act.detail, !d.isEmpty { parts.append(d) }
        return parts.joined(separator: ", ")
    }

    static let spokenReplayUnavailable =
        "REPLAY indisponível · eventos sem timestamps"
    static let replayUnavailableSpoken =
        "replay indisponível porque os eventos não têm timestamps"

    // MARK: Chrome spoken (WAVE residual · proof card)

    static let spokenArtifactsHint = "abre a lista de artefatos deste trace"
    static let spokenReplayScrubber = "scrubber de replay da execução"

    static func spokenArtifactsCTA(count: Int) -> String {
        let noun = count == 1 ? "artefato" : "artefatos"
        return "artefatos desta execução, \(count) \(noun)"
    }

    static func spokenReason(_ reason: String) -> String {
        "motivo, \(reason)"
    }

    static func spokenReplayStep(index: Int, total: Int) -> String {
        let step = min(max(0, index), max(0, total - 1)) + 1
        return "replay da execução, passo \(step) de \(total)"
    }

    static func spokenReplayValue(index: Int, total: Int) -> String {
        let step = min(max(0, index), max(0, total - 1)) + 1
        return "passo \(step) de \(total)"
    }

    static func qualityPackFacts(
        _ q: AtlasQualitySummary
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        let absences: [String] = []
        facts.append("quality_score: \(String(format: "%.2f", q.score))")
        facts.append("quality_status: \(q.status)")
        if q.flagCount > 0 { facts.append("quality_flags: \(q.flagCount)") }
        if q.actionCount > 0 { facts.append("quality_actions: \(q.actionCount)") }
        return (facts, absences)
    }

}
