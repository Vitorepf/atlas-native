import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: ConversationJudgments fused

// MARK: - ConversationMessagesJudgment

// MARK: - Types

/// Exclusive conversation messages surface face (WAVE-072).
enum ConversationMessagesFace: Equatable {
    case loadFail
    case empty
    case messages(Int)

    var productWord: String {
        switch self {
        case .loadFail: return "load_fail"
        case .empty: return "empty"
        case .messages: return "messages"
        }
    }

    var spokenFace: String {
        switch self {
        case .loadFail:
            return "falha ao carregar conversa"
        case .empty:
            return "conversa vazia"
        case .messages(let n):
            let noun = n == 1 ? "turno" : "turnos"
            return "\(n) \(noun)"
        }
    }
}

// MARK: - Judgment

/// Pure messages-surface grammar — face · spoken · pack.
enum ConversationMessagesJudgment {

    static let scrollFABLabel = "ir para o fim da conversa"
    static let scrollFABHint = "volta às mensagens mais recentes"
    static let changeReviewHint = "abre arquivos, diff e provas desta execução"

    static func face(
        hasLoadError: Bool,
        turnCount: Int
    ) -> ConversationMessagesFace {
        if hasLoadError { return .loadFail }
        if turnCount <= 0 { return .empty }
        return .messages(turnCount)
    }

    static func spokenMessages(turnCount: Int) -> String {
        let face = face(hasLoadError: false, turnCount: turnCount)
        switch face {
        case .empty:
            return "conversa, vazia"
        case .messages(let n):
            let noun = n == 1 ? "turno" : "turnos"
            return "conversa, \(n) \(noun)"
        case .loadFail:
            return "conversa, falha ao carregar"
        }
    }

    static func spokenChangeReview(patchCount: Int) -> String {
        if patchCount > 0 {
            let noun = patchCount == 1 ? "patch" : "patches"
            return "revisar mudanças, \(patchCount) \(noun)"
        }
        return "revisar mudanças desta execução"
    }

    static func packFacts(
        hasLoadError: Bool,
        turnCount: Int
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(hasLoadError: hasLoadError, turnCount: turnCount)
        facts.append("messages_face: \(face.productWord)")
        switch face {
        case .loadFail:
            absences.append("conversa falhou ao carregar")
        case .empty:
            absences.append("conversa sem turnos")
            facts.append("messages_turns: 0")
        case .messages(let n):
            facts.append("messages_turns: \(n)")
        }
        return (facts, absences)
    }

    // MARK: Screen chrome spoken (IDLE · was ConversationViewA11y)

    static func spokenToast(_ message: String) -> String { "aviso, \(message)" }

    static let headerContinuityLabel = "continuidade da conversa"
    static let headerContinuityHint = "continuar esta conversa no Mac ou no Terminal"
    static let screenHint = "turnos e composer só com dados da sessão e do model"
}
// MARK: - ConversationDecisionJudgment

// MARK: - Conversation mid-run decision (WAVE-031)

/// Pure judgment: when the strip must elevate **Escolher** over live-run dialect.
enum ConversationDecisionJudgment {

    /// Published choice path exists (actions + job id).
    static func isDecisionRequired(_ bubble: ChatBubble) -> Bool {
        guard let state = bubble.executionPresentationState else { return false }
        guard bubble.executionChoiceJobId != nil else { return false }
        return !state.actions.isEmpty
            && (state.kind == .attentionRequired
                || ConversationExecutionPhase.attention(for: state) == .decision)
    }

    static func isDecisionRequired(state: AtlasExecutionPresentationState, jobId: JobID?) -> Bool {
        guard jobId != nil else { return false }
        return !state.actions.isEmpty
            && (state.kind == .attentionRequired
                || ConversationExecutionPhase.attention(for: state) == .decision)
    }

    /// Product lead when decision is required.
    static var productWord: String { "decision" }

    static var spokenLead: String {
        ConversationExecutionPhase.spokenAttention(.decision)
    }

    static func choiceActions(for bubble: ChatBubble) -> [AtlasExecutionPresentationState.Action] {
        guard isDecisionRequired(bubble) else { return [] }
        return bubble.executionPresentationState?.actions ?? []
    }

    /// Compact strip label when many actions: "Escolher" or first title.
    static func stripChooseLabel(actionCount: Int, firstTitle: String?) -> String {
        if actionCount == 1, let firstTitle, !firstTitle.isEmpty {
            return firstTitle
        }
        return "Escolher"
    }

    // MARK: Pack (WAVE-095)

    static func packFacts(from bubble: ChatBubble?) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        guard let bubble, isDecisionRequired(bubble) else {
            absences.append("sem decisão Escolher publicada neste recorte")
            return (facts, absences)
        }
        let actions = choiceActions(for: bubble)
        facts.append("decision_face: \(productWord)")
        facts.append("decision_action_count: \(actions.count)")
        for action in actions.prefix(8) {
            facts.append("decision_action: \(action.title)")
        }
        if let jobId = bubble.executionChoiceJobId {
            facts.append("decision_job: \(jobId.rawValue)")
        }
        return (facts, absences)
    }

    static func packFacts(
        decisionRequired: Bool,
        actionTitles: [String]
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        guard decisionRequired, !actionTitles.isEmpty else {
            absences.append("sem decisão Escolher publicada neste recorte")
            return (facts, absences)
        }
        facts.append("decision_face: \(productWord)")
        facts.append("decision_action_count: \(actionTitles.count)")
        for title in actionTitles.prefix(8) {
            facts.append("decision_action: \(title)")
        }
        return (facts, absences)
    }
}
// MARK: - ConversationLiveStripJudgment

// MARK: - Judgment

/// Pure live ExecutingStrip CTA + compound spoken grammar (WAVE-093).
/// Phase face stays ConversationExecutionPhase; decision/steer sheets stay 053/058 organs.
enum ConversationLiveStripJudgment {

    static let stopLabel = "parar execução"
    static let stopHint = "interrompe a execução ao vivo"
    static let stopButtonTitle = "Parar"

    static let steerLabel = "redirecionar execução"
    static let steerHint = "abre opções para redirecionar a execução ao vivo"
    static let steerButtonTitle = "Redirecionar"

    static let chooseConfirmHint = "confirma a decisão publicada pelo servidor"
    static let chooseMenuHint = "abre as ações de decisão publicadas"

    // MARK: Visibility

    static func showsSteerCTA(decisionRequired: Bool, hasSteerHandler: Bool) -> Bool {
        !decisionRequired && hasSteerHandler
    }

    static func showsChooseCTA(decisionRequired: Bool, actionCount: Int) -> Bool {
        decisionRequired && actionCount > 0
    }

    // MARK: Spoken CTAs

    static func spokenStop() -> String { stopLabel }
    static func spokenStopHint() -> String { stopHint }
    static func spokenSteer() -> String { steerLabel }
    static func spokenSteerHint() -> String { steerHint }
    static func spokenChooseConfirmHint() -> String { chooseConfirmHint }
    static func spokenChooseMenuHint() -> String { chooseMenuHint }

    // MARK: Compound strip label

    static func spokenStrip(
        bubble: ChatBubble,
        decisionRequired: Bool,
        choiceActionCount: Int,
        face: ConversationExecutionFace,
        reconnectSpoken: String?
    ) -> String {
        var parts: [String] = [ConversationExecutionPhase.primarySpoken(for: bubble)]
        if decisionRequired {
            let noun = choiceActionCount == 1 ? "ação" : "ações"
            parts.append("\(choiceActionCount) \(noun) disponíveis")
        }
        if face == .reconnect, let reconnectSpoken, !reconnectSpoken.isEmpty {
            parts.append(reconnectSpoken)
        } else if let p = bubble.executionProgress, face == .running || face == .multiAgent {
            parts.append("passo \(p.current) de \(p.total), \(p.title)")
        } else if let act = bubble.currentActivity, face == .running || face == .multiAgent {
            parts.append(act.title)
        }
        if face != .finished && face != .quiet {
            let events = bubble.activities.count
            parts.append("\(events) evento\(events == 1 ? "" : "s")")
            if let started = bubble.startedAt {
                let secs = max(0, Int(Date().timeIntervalSince(started)))
                parts.append("\(secs) segundos decorridos")
            }
        }
        if let stats = bubble.diffStats {
            parts.append("mais \(stats.linesAdded), menos \(stats.linesRemoved) linhas")
        }
        return parts.joined(separator: ", ")
    }

    // MARK: Pack

    static func packFacts(
        decisionRequired: Bool,
        choiceActionCount: Int,
        hasSteerHandler: Bool,
        face: ConversationExecutionFace,
        /// WAVE-160: stop only when strip shows live chrome (not finished/quiet).
        showsStop: Bool = true
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("live_strip_phase: \(face.rawValue)")
        facts.append("live_strip_decision_required: \(decisionRequired ? "yes" : "no")")
        if showsStop {
            facts.append("live_strip_stop: available")
        } else {
            absences.append("stop oculto — strip sem chrome live (face finished/quiet)")
        }
        if showsChooseCTA(decisionRequired: decisionRequired, actionCount: choiceActionCount) {
            facts.append("live_strip_cta: choose")
            facts.append("live_strip_choice_count: \(choiceActionCount)")
        } else {
            absences.append("sem CTA de decisão no strip")
        }
        if showsSteerCTA(decisionRequired: decisionRequired, hasSteerHandler: hasSteerHandler) {
            facts.append("live_strip_cta: steer")
        } else {
            absences.append("steer CTA oculto (decisão ou sem handler)")
        }
        return (facts, absences)
    }

    // MARK: Cockpit banner spoken (IDLE · was SilenceWatchdog/ExecutionBanner A11y)

    static func spokenSilenceWatchdog(seconds: Int) -> String {
        "execução ao vivo sem novos eventos há \(seconds) segundos"
    }

    static func spokenExecutionBanner(_ text: String) -> String { text }
}
// MARK: - ConversationAgentLanesJudgment

// MARK: - Types

/// Exclusive multi-agent lanes face (WAVE-049).
enum ConversationAgentLanesFace: Equatable {
    case empty
    case single
    case multi(Int)
    case attention(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .single: return "single"
        case .multi: return "multi"
        case .attention: return "attention"
        }
    }

    var kicker: String? {
        switch self {
        case .empty, .single: return nil
        case .multi: return "LANES"
        case .attention: return "LANES · ATENÇÃO"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem agentes na execução"
        case .single:
            return "1 agente na execução"
        case .multi(let n):
            return "\(n) agentes nas lanes"
        case .attention(let n):
            return n == 1
                ? "1 lane pede atenção"
                : "\(n) lanes pedem atenção"
        }
    }
}

// MARK: - Judgment

/// Pure agent-lanes grammar — rank · face · pack · spoken.
/// Attention: failed → awaiting → running → done (wire-stable).
enum ConversationAgentLanesJudgment {

    /// Lower = higher attention.
    static func statusRank(_ status: String) -> Int {
        switch AtlasTurnStatus(rawValue: status) {
        case .failed: return 0
        case .cancelled: return 1
        case .awaitingUserChoice: return 2
        case .awaitingExternal: return 3
        case .processing: return 4
        case .queued: return 5
        case .succeeded: return 6
        case .unknown: return 7
        }
    }

    static func needsAttention(_ agent: ExecAgent) -> Bool {
        switch AtlasTurnStatus(rawValue: agent.status) {
        case .failed, .cancelled, .awaitingUserChoice, .awaitingExternal:
            return true
        default:
            return false
        }
    }

    static func rank(_ agents: [ExecAgent]) -> [ExecAgent] {
        agents.enumerated().sorted { lhs, rhs in
            let lr = statusRank(lhs.element.status)
            let rr = statusRank(rhs.element.status)
            if lr != rr { return lr < rr }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func face(from agents: [ExecAgent]) -> ConversationAgentLanesFace {
        if agents.isEmpty { return .empty }
        let attention = agents.filter(needsAttention).count
        if attention > 0 { return .attention(attention) }
        if agents.count == 1 { return .single }
        return .multi(agents.count)
    }

    static func label(for agent: ExecAgent) -> String {
        agent.agent ?? providerWord(agent.provider)
    }

    static func providerWord(_ provider: String?) -> String {
        guard let provider, !provider.isEmpty else { return "agente" }
        return provider
            .replacingOccurrences(of: "_cli", with: "")
            .replacingOccurrences(of: "_", with: " ")
    }

    static func packFacts(from agents: [ExecAgent]) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(from: agents)
        facts.append("agent_lanes_face: \(face.productWord)")
        if agents.isEmpty {
            absences.append("nenhum agente publicado neste turno")
            return (facts, absences)
        }
        facts.append("agents: \(agents.count)")
        for a in rank(agents).prefix(6) {
            facts.append("agent: \(label(for: a)) · \(a.status)")
        }
        let attention = agents.filter(needsAttention).count
        if attention > 0 {
            facts.append("lanes_attention: \(attention)")
        }
        return (facts, absences)
    }

    static func spokenSection(from agents: [ExecAgent]) -> String {
        face(from: agents).spokenFace
    }
}
// MARK: - ConversationCanDoJudgment

// MARK: - Judgment

/// Pure conversation mid-thread can_do matrix (WAVE-095).
/// Mirrors Arena 083 / Autônomos 088 — never ongoing-bool alone.
enum ConversationCanDoJudgment {

    /// Live presence snapshot for can_do (casca published signals only).
    struct LiveSignals: Equatable {
        var hasOngoing: Bool
        var hasRunning: Bool
        var hasPaused: Bool
        var hasDecision: Bool
        var decisionActionTitles: [String]
        var hasQueue: Bool
        var queueCount: Int
        var hasPlan: Bool
        var hasLanes: Bool
        /// WAVE-175: change-review accept/reject CTAs published (run or file).
        var hasReviewControl: Bool

        static let quiet = LiveSignals(
            hasOngoing: false,
            hasRunning: false,
            hasPaused: false,
            hasDecision: false,
            decisionActionTitles: [],
            hasQueue: false,
            queueCount: 0,
            hasPlan: false,
            hasLanes: false,
            hasReviewControl: false
        )
    }

    static func liveSignals(
        matchingLive: [LiveSessionSnapshot],
        decisionRequired: Bool = false,
        decisionActionTitles: [String] = [],
        queueCount: Int = 0,
        hasPlan: Bool = false,
        laneCount: Int = 0,
        hasReviewControl: Bool = false
    ) -> LiveSignals {
        let ongoing = matchingLive.contains { $0.timing != .finished }
        return LiveSignals(
            hasOngoing: ongoing,
            hasRunning: matchingLive.contains { $0.timing == .running },
            hasPaused: matchingLive.contains { $0.timing == .paused },
            hasDecision: decisionRequired && !decisionActionTitles.isEmpty,
            decisionActionTitles: decisionActionTitles,
            hasQueue: queueCount > 0,
            queueCount: queueCount,
            hasPlan: hasPlan,
            hasLanes: laneCount > 0,
            hasReviewControl: hasReviewControl
        )
    }

    /// can_do from published CTAs — never invent stop/steer/choose/review write.
    static func occasionCanDo(_ signals: LiveSignals) -> AgenticOccasionPack.CanDo {
        // Decision Escolher is face CTA (local), not NL write.
        if signals.hasDecision {
            return .faceCTALocal
        }
        // Live run/pause: strip exposes stop (+ steer when no decision).
        if signals.hasRunning || signals.hasPaused {
            return .ctaOnlyRunStop
        }
        // WAVE-175: review accept/reject only on sheet CTAs.
        if signals.hasReviewControl {
            return .faceCTALocal
        }
        // Ongoing edge (unknown timing) — face chrome may exist.
        if signals.hasOngoing {
            return .faceCTALocal
        }
        // Quiet thread: read only (queue alone does not authorize write).
        if signals.hasQueue {
            return .readChat
        }
        return .readChat
    }

    static func packFacts(_ signals: LiveSignals) -> (facts: [String], absences: [String], canDo: AgenticOccasionPack.CanDo) {
        let canDo = occasionCanDo(signals)
        var facts: [String] = []
        var absences: [String] = []
        facts.append("can_do: \(canDo.rawValue)")
        facts.append("live_ongoing: \(signals.hasOngoing ? "yes" : "no")")
        facts.append("live_running: \(signals.hasRunning ? "yes" : "no")")
        facts.append("live_paused: \(signals.hasPaused ? "yes" : "no")")
        facts.append("decision_required: \(signals.hasDecision ? "yes" : "no")")
        facts.append("review_control: \(signals.hasReviewControl ? "yes" : "no")")
        if signals.hasDecision {
            facts.append("decision_actions: \(signals.decisionActionTitles.count)")
            for title in signals.decisionActionTitles.prefix(6) {
                facts.append("decision_action: \(title)")
            }
        } else {
            absences.append("sem decisão Escolher publicada neste recorte")
        }
        if signals.hasReviewControl {
            facts.append("review_control_cta: face_sheet_only")
        } else {
            absences.append("sem ações de assinatura da revisão publicadas neste recorte")
        }
        if signals.hasQueue {
            facts.append("queue_followups: \(signals.queueCount)")
        } else {
            absences.append("fila de follow-up vazia neste recorte")
        }
        if !signals.hasPlan {
            absences.append("plano de execução não publicado neste recorte")
        }
        if !signals.hasLanes {
            absences.append("sem agent lanes publicadas neste recorte")
        }
        if signals.hasOngoing && !signals.hasRunning && !signals.hasPaused && !signals.hasDecision && !signals.hasReviewControl {
            absences.append("live sem stop/decision/review CTA tipada — can_do face cauteloso")
        }
        if !signals.hasOngoing && !signals.hasReviewControl {
            absences.append("thread quieta — can_do read_chat (sem face CTA inventada)")
        }
        absences.append("NL de chat ainda não autoriza tools de escrita no wire")
        return (facts, absences, canDo)
    }
}
// MARK: - ConversationThreadShellJudgment

// MARK: - Judgment

/// Pure mid-thread shell identity (WAVE-185) — thread · title · workspace binding.
/// Never invents workspace path or catalog membership.
enum ConversationThreadShellJudgment {

    /// Subject line for AgenticOccasionPack (empty title → honest prefix).
    static func subject(
        threadId: ThreadID,
        title: String
    ) -> String {
        let subjectTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return subjectTitle.isEmpty
            ? "conversa \(threadId.rawValue.prefix(8))"
            : subjectTitle
    }

    /// Pack shell facts for an open conversation route.
    @MainActor
    static func packFacts(
        session: AtlasSession,
        threadId: ThreadID,
        title: String,
        workspaceKey: String?
    ) -> (facts: [String], absences: [String], subject: String) {
        var facts: [String] = []
        var absences: [String] = []
        let subject = subject(threadId: threadId, title: title)

        facts.append("thread_id: \(threadId.rawValue)")
        facts.append("thread_title: \(subject)")

        if let workspaceKey {
            facts.append("workspace_key: \(workspaceKey)")
            if let name = session.workspaces.first(where: { $0.id == workspaceKey })?.name {
                facts.append("workspace_name: \(name)")
            } else {
                absences.append("nome do workspace não listado no catálogo da sessão")
            }
        } else if let thread = session.threads.first(where: { $0.id == threadId.rawValue }) {
            if let ws = thread.workspace, !ws.isEmpty {
                facts.append("workspace_path: \(ws)")
            } else {
                absences.append("workspace da thread não publicado no catálogo local")
            }
        } else {
            absences.append("thread ainda não listada no catálogo local da sessão")
        }

        absences.append("não invente grafo/Arena/Autônomos neste pack de conversa")
        return (facts, absences, subject)
    }
}

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

    static let defaultPromptQuote = "O que você quer pensar agora?"
    static let suggestionHint = "envia esta pergunta agora"

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
        cleanPrompt(prompt) ?? defaultPromptQuote
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

    static func destinationLabel(_ handoff: AtlasAiSurfaceHandoff) -> String {
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
        let dest = destinationLabel(handoff)
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
        let dest = destinationLabel(handoff)
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
