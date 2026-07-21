import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: density split — steer/phase/empty

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

    static func productScope(_ scope: AtlasInteractionSteerScope) -> String {
        switch scope {
        case .currentStep: return "passo atual"
        case .replan: return "replanejar"
        }
    }

    static func spokenScope(_ scope: AtlasInteractionSteerScope) -> String {
        "escopo \(productScope(scope))"
    }

    // MARK: Receipt

    static func receiptLine(_ receipt: AtlasInteractionSteerResponse) -> String {
        if receipt.isAccepted {
            return "na fila do próximo checkpoint"
        }
        return "rejeitado · \(productRejectionReason(receipt.reason))"
    }

    static func productRejectionReason(
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
        return "último recibo, steering rejeitado, \(productRejectionReason(receipt.reason))"
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

// MARK: - ConversationThreadJudgments

// MARK: - ConversationEmptyJudgment

// MARK: - Types

/// Exclusive conversation empty-editorial face (WAVE-084).
/// Product words: silence | default_prompt | custom_prompt | suggestions(N).
enum ConversationEmptyFace: Equatable {
    case silence
    case defaultHome
    case customPrompt
    case suggestions(Int)

    var productWord: String {
        switch self {
        case .silence: return "silence"
        case .defaultHome: return "default_prompt"
        case .customPrompt: return "custom_prompt"
        case .suggestions(let n): return "suggestions(\(n))"
        }
    }

    var spokenFace: String {
        switch self {
        case .silence:
            return "partida em silêncio"
        case .defaultHome:
            return "partida home"
        case .customPrompt:
            return "convite customizado"
        case .suggestions(let n):
            let noun = n == 1 ? "sugestão" : "sugestões"
            return "\(n) \(noun)"
        }
    }
}

// MARK: - Judgment

/// Pure empty-editorial grammar — face · prompt/chips resolve · spoken · pack.
/// WAVE-002 law: invite ≡ emptyPrompt ≡ suggestions ≡ turnFacts same occasion.
/// Never invents chips; Home catalog only when `isHomePartida`.
enum ConversationEmptyJudgment {

    static let productDefaultPromptQuote = "O que você quer pensar agora?"
    static let spokenSuggestionHint = "envia esta pergunta agora"

    // MARK: Resolve

    static func cleanPrompt(_ prompt: String?) -> String? {
        guard let raw = prompt?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return nil
        }
        return raw
    }

    static func cleanSuggestions(_ raw: [String]?) -> [String] {
        (raw ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// Resolved chips: host list wins; Home catalog only on home partida when nil.
    static func resolvedSuggestions(
        suggestions: [String]?,
        isHomePartida: Bool,
        hasWorkspaces: Bool
    ) -> [String] {
        if let suggestions {
            return cleanSuggestions(suggestions)
        }
        if isHomePartida {
            return HomeAskContext.emptySuggestions(hasWorkspaces: hasWorkspaces)
        }
        return []
    }

    static func resolvedPrompt(_ prompt: String?) -> String {
        cleanPrompt(prompt) ?? productDefaultPromptQuote
    }

    // MARK: Face

    static func face(
        prompt: String?,
        suggestions: [String]?,
        isHomePartida: Bool,
        hasWorkspaces: Bool = false
    ) -> ConversationEmptyFace {
        let chips = resolvedSuggestions(
            suggestions: suggestions,
            isHomePartida: isHomePartida,
            hasWorkspaces: hasWorkspaces
        )
        let hasPrompt = cleanPrompt(prompt) != nil

        if isHomePartida {
            if chips.isEmpty && !hasPrompt { return .silence }
            return .defaultHome
        }
        if !chips.isEmpty { return .suggestions(chips.count) }
        if hasPrompt { return .customPrompt }
        return .silence
    }

    // MARK: Spoken (a11y)

    static func spokenPrompt(_ prompt: String?) -> String {
        let text = resolvedPrompt(prompt)
        return "conversa vazia, \(text.lowercased())"
    }

    static func spokenSuggestion(_ text: String, index: Int, total: Int) -> String {
        "sugestão \(index + 1) de \(total), \(text)"
    }

    static func spokenEmptyOrgan(
        prompt: String?,
        suggestions: [String]?,
        isHomePartida: Bool,
        hasWorkspaces: Bool = false
    ) -> String {
        let f = face(
            prompt: prompt,
            suggestions: suggestions,
            isHomePartida: isHomePartida,
            hasWorkspaces: hasWorkspaces
        )
        let chips = resolvedSuggestions(
            suggestions: suggestions,
            isHomePartida: isHomePartida,
            hasWorkspaces: hasWorkspaces
        )
        var parts = [f.spokenFace, spokenPrompt(prompt)]
        if !chips.isEmpty {
            parts.append("\(chips.count) chip\(chips.count == 1 ? "" : "s")")
        }
        return parts.joined(separator: ", ")
    }

    // MARK: Pack

    static func packFacts(
        prompt: String?,
        suggestions: [String]?,
        isHomePartida: Bool,
        hasWorkspaces: Bool = false
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let f = face(
            prompt: prompt,
            suggestions: suggestions,
            isHomePartida: isHomePartida,
            hasWorkspaces: hasWorkspaces
        )
        let chips = resolvedSuggestions(
            suggestions: suggestions,
            isHomePartida: isHomePartida,
            hasWorkspaces: hasWorkspaces
        )
        facts.append("empty_face: \(f.productWord)")
        facts.append("empty_suggestions_count: \(chips.count)")
        if isHomePartida {
            facts.append("empty_host: home_partida")
        } else {
            facts.append("empty_host: occasion")
        }
        if cleanPrompt(prompt) == nil {
            absences.append("empty_prompt não publicado — quote default local")
        }
        switch f {
        case .silence:
            absences.append("partida sem chips nem convite custom")
        case .defaultHome:
            facts.append("empty_catalog: home")
        case .customPrompt:
            absences.append("chips não publicados nesta ocasião")
        case .suggestions:
            break
        }
        return (facts, absences)
    }
}

// MARK: - ConversationHandoffJudgment

// MARK: - Judgment

// MARK: - Types

/// Exclusive conversation surface-handoff face (WAVE-045).
enum ConversationHandoffFace: Equatable {
    case absent
    case pending
    case ready
    case other(String)

    var productWord: String {
        switch self {
        case .absent: return "absent"
        case .pending: return "pending"
        case .ready: return "ready"
        case .other: return "other"
        }
    }

    var spokenStatus: String {
        switch self {
        case .absent: return "sem handoff"
        case .pending: return "enviando"
        case .ready: return "pronto"
        case .other(let raw): return atlasHandoffStatusEditorial(raw)
        }
    }
}

// MARK: - Judgment

/// Pure continuity handoff grammar — face · copy · pack · spoken.
enum ConversationHandoffJudgment {

    static func face(from handoff: AtlasAiSurfaceHandoff?) -> ConversationHandoffFace {
        guard let handoff else { return .absent }
        switch handoff.status {
        case "ready": return .ready
        case "pending": return .pending
        default: return .other(handoff.status)
        }
    }

    static func isReady(_ handoff: AtlasAiSurfaceHandoff) -> Bool {
        face(from: handoff) == .ready
    }

    static func isPending(_ handoff: AtlasAiSurfaceHandoff) -> Bool {
        face(from: handoff) == .pending
    }

    static func productDestination(_ handoff: AtlasAiSurfaceHandoff) -> String {
        atlasSurfaceLabel(handoff.toSurface)
    }

    static func routeLine(_ handoff: AtlasAiSurfaceHandoff) -> String {
        "\(atlasSurfaceLabel(handoff.fromSurface)) → \(atlasSurfaceLabel(handoff.toSurface))"
    }

    static func threadPrefix(_ handoff: AtlasAiSurfaceHandoff) -> String {
        editorialThreadPrefix(handoff.threadId)
    }

    static func ageFragment(_ handoff: AtlasAiSurfaceHandoff, now: Date = Date()) -> String? {
        guard let raw = handoff.createdAt, let date = AtlasTime.date(raw) else { return nil }
        return atlasRelativeAgePT(since: date, now: now)
    }

    static func headline(_ handoff: AtlasAiSurfaceHandoff) -> String {
        let dest = productDestination(handoff)
        switch face(from: handoff) {
        case .ready: return "Pronto no \(dest)"
        case .pending: return "Enviando para o \(dest)…"
        case .other: return "Continuidade para \(dest)"
        case .absent: return "Continuidade"
        }
    }

    static func subline(_ handoff: AtlasAiSurfaceHandoff, now: Date = Date()) -> String {
        let route = routeLine(handoff)
        let thread = threadPrefix(handoff)
        let age = ageFragment(handoff, now: now)
        switch face(from: handoff) {
        case .ready:
            var parts = [route, "mesma thread \(thread)", "sem prompt duplicado"]
            if let age { parts.append("há \(age)") }
            return parts.joined(separator: " · ")
        case .pending, .other, .absent:
            var parts = [face(from: handoff).spokenStatus, route, "thread \(thread)"]
            if let age { parts.append("há \(age)") }
            return parts.joined(separator: " · ")
        }
    }

    static func spoken(_ handoff: AtlasAiSurfaceHandoff, now: Date = Date()) -> String {
        let dest = productDestination(handoff)
        let thread = threadPrefix(handoff)
        let age = ageFragment(handoff, now: now).map { ", há \($0)" } ?? ""
        switch face(from: handoff) {
        case .ready:
            return "continuidade pronta no \(dest), mesma thread \(thread), sem prompt duplicado\(age)"
        case .pending:
            return "continuidade enviando para o \(dest), mesma thread \(thread)\(age)"
        case .other, .absent:
            return "recibo de continuidade para \(dest), \(face(from: handoff).spokenStatus), thread \(thread)\(age)"
        }
    }

    static func packFacts(from handoff: AtlasAiSurfaceHandoff?) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(from: handoff)
        facts.append("handoff_face: \(face.productWord)")
        guard let handoff else {
            absences.append("nenhum handoff de superfície neste recorte")
            return (facts, absences)
        }
        facts.append("handoff_status: \(handoff.status)")
        facts.append("route: \(routeLine(handoff))")
        facts.append("thread: \(threadPrefix(handoff))")
        facts.append("to_surface: \(handoff.toSurface)")
        facts.append("from_surface: \(handoff.fromSurface)")
        if let age = ageFragment(handoff) {
            facts.append("age: \(age)")
        } else {
            absences.append("created_at ausente no handoff")
        }
        return (facts, absences)
    }
}

// MARK: - Receipt

struct ConversationHandoffReceipt: View {
    let handoff: AtlasAiSurfaceHandoff
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    // WAVE-045: face owned by Judgment.
    var face: ConversationHandoffFace { ConversationHandoffJudgment.face(from: handoff) }
    var isReady: Bool { ConversationHandoffJudgment.isReady(handoff) }
    var isPending: Bool { ConversationHandoffJudgment.isPending(handoff) }

    var body: some View {
        receiptChrome(receiptRowStack)
    }

    // MARK: - Layout

    var receiptRowStack: some View {
        HStack(spacing: 9) {
            receiptIcon
            receiptCopy
            Spacer(minLength: 0)
        }
    }

    var receiptIcon: some View {
        Image(systemName: isReady ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
            .atlasSans(12, .semibold)
            .foregroundStyle(isReady ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .modifier(ReceiptSpinEffect(active: isPending && !reduceMotion))
            .accessibilityHidden(true)
    }

    var receiptCopy: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(ConversationHandoffJudgment.headline(handoff))
                .font(.system(.footnote, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(ConversationHandoffJudgment.subline(handoff))
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }

    func receiptChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.goldVeil))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.goldBorder, lineWidth: 1))
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 2)
            .padding(.bottom, 8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ConversationHandoffJudgment.spoken(handoff))
            .accessibilityIdentifier(A11yID.continuityHandoffReceipt)
            .accessibilityValue(face.productWord)
    }
}

// iOS 17 compat: `.symbolEffect(.rotate,…)` exige iOS 18. Rotação contínua
// própria (deploymentTarget = iOS 17), respeitando Reduce Motion via `active`.
private struct ReceiptSpinEffect: ViewModifier {
    let active: Bool
    @State private var spinning = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(active && spinning ? 360 : 0))
            .animation(active ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                       value: spinning)
            .onAppear { if active { spinning = true } }
            .onChange(of: active) { _, now in spinning = now }
    }
}
