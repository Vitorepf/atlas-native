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
