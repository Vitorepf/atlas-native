import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: density split — outline/stale/steer/phase

// MARK: - ConversationOutlineJudgment

// MARK: - Judgment

// MARK: - Types

/// Exclusive conversation outline face (WAVE-079).
enum ConversationOutlineFace: Equatable {
    case empty
    case turns(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .turns: return "turns"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem turnos carregados nesta thread"
        case .turns(let n):
            let noun = n == 1 ? "turno" : "turnos"
            return "\(n) \(noun)"
        }
    }
}

// MARK: - Judgment

/// Pure conversation-outline grammar — face · spoken · pack.
enum ConversationOutlineJudgment {

    static func face(turnCount: Int) -> ConversationOutlineFace {
        turnCount <= 0 ? .empty : .turns(turnCount)
    }

    static func spokenSheetLabel(turnCount: Int) -> String {
        let face = face(turnCount: turnCount)
        switch face {
        case .empty:
            return "índice da conversa, \(face.spokenFace)"
        case .turns:
            return "índice da conversa, \(face.spokenFace)"
        }
    }

    static func spokenEmptySheet() -> String {
        "índice da conversa, sem turnos carregados nesta thread"
    }

    static func spokenRole(_ role: String) -> String {
        role == "user" ? "você" : "Atlas"
    }

    static func spokenSnippet(from text: String) -> String {
        let trimmed = AtlasMarkdown.plainText(text)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return "sem texto visível neste turno"
        }
        return String(trimmed.prefix(140))
    }

    static func spokenRow(index: Int, role: String, snippet: String) -> String {
        "turno \(index), \(spokenRole(role)), \(snippet)"
    }

    static func packFacts(turnCount: Int) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(turnCount: turnCount)
        facts.append("outline_face: \(face.productWord)")
        switch face {
        case .empty:
            absences.append("índice sem turnos nesta thread")
            facts.append("outline_turns: 0")
        case .turns(let n):
            facts.append("outline_turns: \(n)")
        }
        return (facts, absences)
    }

    // MARK: Chrome spoken (IDLE · was ConversationViewA11y outline)

    static func spokenOutlineControl(turnCount: Int) -> String {
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "índice da conversa, \(turnCount) \(noun)"
    }

    static let outlineControlHint = "abre o índice editorial dos turnos desta conversa"
}

// MARK: - Sheet

// MARK: - Índice da conversa (fusão idle dos peels Outline*)

struct ConversationOutlineSheet: View {
    let bubbles: [ChatBubble]
    var reduceMotion: Bool = false

    var body: some View {
        outlineA11yBind(
            SheetShell(title: "Índice da conversa") {
                outlineSheetContent
            }
        )
    }

    func outlineA11yBind<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.conversationOutlineSheet)
            .accessibilityLabel(ConversationOutlineJudgment.spokenSheetLabel(turnCount: bubbles.count))
            .accessibilityValue(
                ConversationOutlineJudgment.face(turnCount: bubbles.count).productWord
            )
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: bubbles.map(\.id))
    }

    @ViewBuilder
    var outlineSheetContent: some View {
        if bubbles.isEmpty {
            outlineEmpty
        } else {
            outlineRowList
        }
    }

    var outlineEmpty: some View {
        Text("Nenhum turno carregado nesta thread.")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 12)
            .accessibilityLabel(ConversationOutlineJudgment.spokenEmptySheet())
            .accessibilityAddTraits(.isStaticText)
    }

    @ViewBuilder
    var outlineRowList: some View {
        ForEach(Array(bubbles.enumerated()), id: \.element.id) { index, bubble in
            ConversationOutlineRow(index: index + 1, bubble: bubble, reduceMotion: reduceMotion)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 6)))
        }
    }
}

struct ConversationOutlineRow: View {
    let index: Int
    let bubble: ChatBubble
    var reduceMotion: Bool = false

    var body: some View {
        outlineLead
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 10)
            .accessibilityIdentifier(A11yID.conversationOutlineRow(index))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                ConversationOutlineJudgment.spokenRow(index: index, role: bubble.role, snippet: snippet)
            )
    }

    var snippet: String {
        ConversationOutlineJudgment.spokenSnippet(from: bubble.text)
    }

    var outlineLead: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            outlineLeadIndex
            outlineLeadSnippetStack
            Spacer(minLength: 0)
        }
    }

    var outlineLeadIndex: some View {
        Text(String(format: "%02d", index))
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.accent)
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityHidden(true)
    }

    var outlineLeadSnippetStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            outlineLeadRole
            Text(snippet)
                .font(.system(.footnote))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }

    var outlineLeadRole: some View {
        Text(bubble.role == "user" ? "Você" : "Atlas")
            .font(.system(.caption, weight: .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityHidden(true)
    }
}

// MARK: - ConversationStaleReadJudgment

// MARK: - Judgment

// MARK: - Types

/// Exclusive cache-read honesty face (WAVE-060).
enum ConversationStaleReadFace: Equatable {
    case confirming
    case fresh
    case aged
    case stale

    var productWord: String {
        switch self {
        case .confirming: return "confirming"
        case .fresh: return "fresh"
        case .aged: return "aged"
        case .stale: return "stale"
        }
    }

    var spokenFace: String {
        switch self {
        case .confirming: return "histórico salvo atualizado"
        case .fresh: return "leitura recente em cache"
        case .aged: return "leitura envelhecendo em cache"
        case .stale: return "leitura envelhecida em cache"
        }
    }
}

// MARK: - Judgment

/// Pure stale-read seal grammar — face · caption · spoken · pack.
enum ConversationStaleReadJudgment {

    /// Fresh < 5m · aged < 1h · stale ≥ 1h (display buckets only).
    static func face(
        capturedAt: Date,
        now: Date = Date(),
        confirming: Bool
    ) -> ConversationStaleReadFace {
        if confirming { return .confirming }
        let seconds = max(0, Int(now.timeIntervalSince(capturedAt)))
        if seconds < 5 * 60 { return .fresh }
        if seconds < 60 * 60 { return .aged }
        return .stale
    }

    static func displayCaption(
        capturedAt: Date,
        now: Date = Date(),
        confirming: Bool,
        reduceMotion: Bool
    ) -> String {
        if confirming {
            return reduceMotion ? "leitura atualizada" : "leitura sincronizada"
        }
        return "visto há \(atlasRelativeAgePT(since: capturedAt, now: now))"
    }

    static func spokenLabel(
        capturedAt: Date,
        now: Date = Date(),
        confirming: Bool,
        reduceMotion: Bool
    ) -> String {
        let face = face(capturedAt: capturedAt, now: now, confirming: confirming)
        if confirming {
            return reduceMotion
                ? "histórico salvo atualizado"
                : "histórico salvo atualizado após sincronizar"
        }
        let age = atlasRelativeAgePT(since: capturedAt, now: now)
        return "histórico salvo visto há \(age), \(face.spokenFace)"
    }

    static func packFacts(
        capturedAt: Date?,
        now: Date = Date(),
        confirming: Bool = false
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        guard let capturedAt else {
            absences.append("sem captura de cache neste recorte")
            return (facts, absences)
        }
        let face = face(capturedAt: capturedAt, now: now, confirming: confirming)
        facts.append("stale_read_face: \(face.productWord)")
        facts.append("cache_age_s: \(max(0, Int(now.timeIntervalSince(capturedAt))))")
        if confirming {
            facts.append("cache_confirming: true")
        }
        return (facts, absences)
    }
}

// MARK: - Seal chrome

extension StaleReadSeal {
    @ViewBuilder
    func sealBody(now: Date) -> some View {
        sealChrome(now: now)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ConversationStaleReadJudgment.spokenLabel(
                capturedAt: capturedAt,
                now: now,
                confirming: confirming,
                reduceMotion: reduceMotion
            ))
    }
}

extension StaleReadSeal {
    func sealCaptionRow(now: Date) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.arrow.circlepath")
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            Text(ConversationStaleReadJudgment.displayCaption(
                capturedAt: capturedAt,
                now: now,
                confirming: confirming,
                reduceMotion: reduceMotion
            ))
            .font(AtlasFont.mono(11))
            .modifier(NumericTextTransition(enabled: !reduceMotion && !confirming))
            .accessibilityHidden(true)
        }
        .foregroundStyle(AtlasTheme.textTertiary)
    }
}

extension StaleReadSeal {
    @ViewBuilder
    func sealChrome(now: Date) -> some View {
        sealCaptionRow(now: now)
            .frame(maxWidth: .infinity, alignment: .leading)
            .scaleEffect(confirming && !reduceMotion ? 1.045 : 1)
            .opacity(confirming && !reduceMotion ? 0.72 : 1)
            .animation(confirming && !reduceMotion ? .easeInOut(duration: 0.32) : nil, value: confirming)
    }
}


extension StaleReadSeal {
    @ViewBuilder
    func sealTimelineGate(now: Date) -> some View {
        if reduceMotion || confirming {
            sealBody(now: now)
        } else {
            TimelineView(.periodic(from: Date(), by: 60)) { context in
                sealBody(now: context.date)
            }
        }
    }
}

struct StaleReadSeal: View {
    let capturedAt: Date
    let confirming: Bool
    let reduceMotion: Bool

    var body: some View {
        sealTimelineGate(now: Date())
            .accessibilityIdentifier(A11yID.conversationStaleReadSeal)
            .accessibilityValue(
                ConversationStaleReadJudgment.face(
                    capturedAt: capturedAt,
                    confirming: confirming
                ).productWord
            )
            .accessibilityAddTraits(confirming || reduceMotion ? .isStaticText : .updatesFrequently)
    }
}

// MARK: - ConversationSteerJudgment

// MARK: - Types

/// Exclusive mid-run steer face (WAVE-053).
enum ConversationSteerFace: Equatable {
    /// Form open, instruction empty.
    case composing
    /// Instruction ready to submit.
    case ready
    /// Last receipt for this trace accepted (queued next checkpoint).
    case accepted
    /// Last receipt for this trace rejected with public reason.
    case rejected

    var productWord: String {
        switch self {
        case .composing: return "composing"
        case .ready: return "ready"
        case .accepted: return "accepted"
        case .rejected: return "rejected"
        }
    }

    var kicker: String {
        switch self {
        case .composing: return "Redirecionar"
        case .ready: return "Pronto para enviar"
        case .accepted: return "Enfileirado"
        case .rejected: return "Recusado"
        }
    }

    var spokenFace: String {
        switch self {
        case .composing:
            return "redirecionar, instrução vazia"
        case .ready:
            return "pronto para enviar instrução de redirecionamento"
        case .accepted:
            return "instrução enfileirada para o próximo checkpoint seguro"
        case .rejected:
            return "steering recusado"
        }
    }
}

// MARK: - Judgment

/// Pure steer grammar — face · submit · scope · receipt · pack.
enum ConversationSteerJudgment {

    static func hasInstruction(_ instruction: String) -> Bool {
        !instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static func allowsSubmit(instruction: String) -> Bool {
        hasInstruction(instruction)
    }

    /// Receipt only when it belongs to this trace (never cross-thread lie).
    static func matchedReceipt(
        last: AtlasInteractionSteerResponse?,
        traceId: TraceID
    ) -> AtlasInteractionSteerResponse? {
        guard let last else { return nil }
        if let receiptTrace = last.traceId, receiptTrace != traceId.rawValue {
            return nil
        }
        return last
    }

    static func face(
        instruction: String,
        last: AtlasInteractionSteerResponse?,
        traceId: TraceID
    ) -> ConversationSteerFace {
        if let receipt = matchedReceipt(last: last, traceId: traceId) {
            return receipt.isAccepted ? .accepted : .rejected
        }
        return hasInstruction(instruction) ? .ready : .composing
    }

    // MARK: Scope product words (not wire raw)

    static func scopeProductWord(_ scope: AtlasInteractionSteerScope) -> String {
        switch scope {
        case .currentStep: return "passo_atual"
        case .replan: return "replanejar"
        }
    }

    static func scopeLabel(_ scope: AtlasInteractionSteerScope) -> String {
        switch scope {
        case .currentStep: return "passo atual"
        case .replan: return "replanejar"
        }
    }

    static func spokenScope(_ scope: AtlasInteractionSteerScope) -> String {
        "escopo \(scopeLabel(scope))"
    }

    // MARK: Receipt

    static func receiptLine(_ receipt: AtlasInteractionSteerResponse) -> String {
        if receipt.isAccepted {
            return "na fila do próximo checkpoint"
        }
        return "rejeitado · \(rejectionReasonLabel(receipt.reason))"
    }

    static func rejectionReasonLabel(
        _ reason: AtlasInteractionSteerRejectionReason?
    ) -> String {
        guard let reason else { return "motivo indisponível" }
        switch reason {
        case .instructionRequired: return "instrução obrigatória"
        case .invalidScope: return "escopo inválido"
        case .traceWithoutThread: return "execução sem thread"
        case .noActiveJob: return "sem job ativo"
        }
    }

    static func spokenReceipt(_ receipt: AtlasInteractionSteerResponse) -> String {
        if receipt.isAccepted {
            return "último recibo, instrução enfileirada para o próximo checkpoint seguro"
        }
        return "último recibo, steering rejeitado, \(rejectionReasonLabel(receipt.reason))"
    }

    // MARK: Sheet chrome

    static func spokenSheetTitle(traceId: TraceID) -> String {
        "redirecionar execução \(traceId.rawValue)"
    }

    // MARK: Submit a11y

    static func spokenSubmitLabel(allowsSubmit: Bool) -> String {
        allowsSubmit
            ? "enviar instrução de redirecionamento"
            : "enviar indisponível, instrução vazia"
    }

    static func spokenSubmitHint(allowsSubmit: Bool) -> String {
        allowsSubmit
            ? "envia a instrução ao Atlas no escopo selecionado"
            : "escreva o que muda a partir daqui"
    }

    // MARK: Pack

    static func packFacts(
        instruction: String,
        scope: AtlasInteractionSteerScope,
        last: AtlasInteractionSteerResponse?,
        traceId: TraceID
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(instruction: instruction, last: last, traceId: traceId)
        facts.append("steer_face: \(face.productWord)")
        facts.append("steer_scope: \(scopeProductWord(scope))")
        facts.append("steer_allows_submit: \(allowsSubmit(instruction: instruction))")
        if hasInstruction(instruction) {
            let trimmed = instruction.trimmingCharacters(in: .whitespacesAndNewlines)
            let snip = trimmed.count <= 80 ? trimmed : String(trimmed.prefix(79)) + "…"
            facts.append("steer_instruction_draft: \(snip)")
        } else {
            absences.append("instrução de steer vazia neste recorte")
        }
        if let receipt = matchedReceipt(last: last, traceId: traceId) {
            facts.append("steer_receipt: \(receipt.status.rawValue)")
            facts.append("steer_receipt_line: \(receiptLine(receipt))")
            if let reason = receipt.reason {
                facts.append("steer_reject_reason: \(reason.rawValue)")
            }
        } else {
            absences.append("nenhum recibo de steer para este trace")
        }
        return (facts, absences)
    }
}

// MARK: - ConversationExecutionPhase

// MARK: - Face · attention types

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

// MARK: - Phase grammar

enum ConversationExecutionPhase {
    // MARK: Face resolution

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
        case .attentionRequired:
            // WAVE-031: Core treats choice as paused attention — not live-run dialect.
            return .paused
        case .replanning, .awaitingExternal:
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
    // MARK: Strip chrome

    static func stripShowsLiveChrome(_ bubble: ChatBubble) -> Bool {
        let face = face(for: bubble)
        return face != .finished && face != .quiet
    }

    // MARK: Spoken

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

    // MARK: - WAVE-027 primary chrome + presence-ongoing selection

    /// Primary kicker = spoken face words (strip / card / LiveNow lead).
    /// WAVE-031: when attention is decision, lead with decision product words.
    static func primarySpoken(
        _ face: ConversationExecutionFace,
        attention: ConversationExecutionAttention? = nil
    ) -> String {
        if attention == .decision {
            return spokenAttention(.decision)
        }
        return spokenFace(face)
    }

    static func primarySpoken(for bubble: ChatBubble) -> String {
        let face = face(for: bubble)
        let attention: ConversationExecutionAttention? = {
            guard let state = bubble.executionPresentationState else { return nil }
            return self.attention(for: state)
        }()
        if ConversationDecisionJudgment.isDecisionRequired(bubble) {
            return ConversationDecisionJudgment.spokenLead
        }
        return primarySpoken(face, attention: attention)
    }

    static func primarySpoken(for state: AtlasExecutionPresentationState) -> String {
        let face = face(for: state)
        let attention = attention(for: state)
        if attention == .decision {
            return spokenAttention(.decision)
        }
        return primarySpoken(face, attention: attention)
    }

    /// Product word for mono chrome (uppercase in UI when needed).
    static func primaryProduct(_ face: ConversationExecutionFace) -> String {
        face.productWord
    }

    /// Presence still demands operator attention chrome (not finished/quiet).
    static func isPresenceOngoing(_ bubble: ChatBubble) -> Bool {
        if let presence = bubble.executionPresence, presence.isOngoing {
            return true
        }
        if bubble.streaming { return true }
        let face = face(for: bubble)
        switch face {
        case .finished, .quiet:
            return false
        case .reconnect, .paused, .multiAgent, .running:
            return true
        }
    }

    /// Composer / strip selection: ongoing presence first, not streaming-only.
    /// Fallback: last streaming, then last bubble with live strip chrome.
    static func selectPresenceBubble(from bubbles: [ChatBubble]) -> ChatBubble? {
        if let ongoing = bubbles.reversed().first(where: { bubble in
            bubble.traceId != nil && bubble.executionPresence?.isOngoing == true
        }) {
            return ongoing
        }
        if let streaming = bubbles.last(where: \.streaming) {
            return streaming
        }
        return bubbles.reversed().first(where: { isPresenceOngoing($0) && stripShowsLiveChrome($0) })
    }

    /// Agent lane vocabulary under multi/running — attention words or silence.
    /// Avoids parallel “processando/na fila” dialect fighting the face.
    static func agentStatusWord(rawStatus: String) -> String? {
        switch AtlasTurnStatus(rawValue: rawStatus) {
        case .queued, .processing:
            return nil // silence — face carries running/multi
        case .awaitingUserChoice:
            return spokenAttention(.decision)
        case .awaitingExternal:
            return spokenAttention(.awaiting)
        case .succeeded:
            return primaryProduct(.finished)
        case .failed:
            return spokenAttention(.failed)
        case .cancelled:
            return "cancelado"
        case .unknown(let raw):
            return raw.isEmpty ? nil : raw
        }
    }

    // MARK: Glance ↔ face adapter (WAVE-018 / 027 honesty)

    /// Maps in-app face → glance ContentState vocabulary.
    /// reconnect/quiet have **no** dedicated glance kind — honesty absence, not invention.
    enum GlanceAdapter {
        case finished
        case multiSession
        case paused
        case running
        /// No ContentState field — do not invent glance chrome.
        case unmapped(reason: String)

        static func map(_ face: ConversationExecutionFace) -> GlanceAdapter {
            switch face {
            case .finished: return .finished
            case .multiAgent: return .multiSession
            case .paused: return .paused
            case .running: return .running
            case .reconnect:
                return .unmapped(reason: "reconnect is strip-primary dual-surface; glance has no reconnect kind")
            case .quiet:
                return .unmapped(reason: "quiet is silence; glance omits quiet as a distinct kind")
            }
        }

        var productWord: String {
            switch self {
            case .finished: return "finished"
            case .multiSession: return "multi"
            case .paused: return "paused"
            case .running: return "running"
            case .unmapped: return "—"
            }
        }
    }
}
