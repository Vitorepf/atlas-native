import Foundation
import AtlasCore

// MARK: - Conversation mid-thread occasion (WAVE-029)

/// Compiles turnFacts for an **open thread** — never Home partida.
/// Surface purity: `conversation` or `conversation.workspace`.
enum ConversationOccasionPack {

    static let invite = "continue nesta conversa"

    static var emptySuggestions: [String] {
        [
            "O que mudou neste fio?",
            "Resume o estado da execução",
            "O que preciso julgar agora?"
        ]
    }

    /// Live mid-thread slice from ConversationModel (WAVE-106).
    /// Never invent: only published bubble/queue/agents.
    /// Not Equatable: handoff DTO is Codable-only (no Core change).
    struct PublishedSlice {
        var presenceBubble: ChatBubble?
        var queued: [QueuedMessage]
        var agents: [ExecAgent]
        /// WAVE-160: last steer receipt from model (nil → absence).
        var lastSteerReceipt: AtlasInteractionSteerResponse? = nil
        /// WAVE-161: surface handoff receipt (nil → absence).
        var latestSurfaceHandoff: AtlasAiSurfaceHandoff? = nil
        /// WAVE-163: change review for presence trace (nil → absence).
        var changeReview: AtlasTraceChangeReview? = nil
        /// WAVE-163: whether review load finished for this trace.
        var changeReviewLoadFinished: Bool = false
        /// WAVE-164: composer draft strip + effort + cache seal.
        var drafts: [LocalDraft] = []
        var uploadPercent: Double? = nil
        var effort: AtlasComputeEffort = .auto
        var cacheCapturedAt: Date? = nil
        var artifacts: [AtlasTraceArtifacts.Item] = []
        /// WAVE-166: outline turn count + toolbar chrome.
        var turnCount: Int = 0
        var toolbarMode: String = ""
        var toolbarWorkspaceName: String? = nil

        static let unbound = PublishedSlice(
            presenceBubble: nil,
            queued: [],
            agents: []
        )

        var hasModel: Bool { true }
    }

    /// Pure-ish compile from route + hub presence (casca only).
    /// `published` hydrates queue/plan/lanes/decision from the live model when bound.
    @MainActor
    static func facts(
        session: AtlasSession,
        threadId: ThreadID,
        title: String,
        workspaceKey: String? = nil,
        published: PublishedSlice? = nil
    ) -> String {
        var anchors: [String] = []
        var facts: [String] = []
        var absences: [String] = []

        let subjectTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let subject = subjectTitle.isEmpty ? "conversa \(threadId.rawValue.prefix(8))" : subjectTitle

        facts.append("thread_id: \(threadId.rawValue)")
        facts.append("thread_title: \(subject)")

        if let workspaceKey {
            facts.append("workspace_key: \(workspaceKey)")
            if let name = session.workspaces.first(where: { $0.id == workspaceKey })?.name {
                facts.append("workspace_name: \(name)")
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

        // Live sessions matching this thread — face product words, not raw phaseTitle lead.
        let matchingLive = TurnPresence.shared.liveSessions.filter { $0.threadId == threadId }
            + session.remoteLiveSessions.filter { $0.threadId == threadId }
        if matchingLive.isEmpty {
            facts.append("sessoes_vivas_deste_fio: 0")
        } else {
            facts.append("sessoes_vivas_deste_fio: \(matchingLive.count)")
            for s in matchingLive.prefix(4) {
                let face = ConversationExecutionPhase.face(for: s)
                let product = ConversationExecutionPhase.primaryProduct(face)
                anchors.append("live · \(s.title) · \(product)")
                // phaseTitle as secondary detail only
                if !s.phaseTitle.isEmpty {
                    facts.append("live_detail · \(s.title) · \(s.phaseTitle)")
                }
            }
        }

        // Hub-wide live count without claiming other threads are this one.
        let hubLive = TurnPresence.shared.liveSessions.count
        if hubLive > matchingLive.count {
            facts.append("sessoes_vivas_hub_global: \(hubLive) (outras conversas podem estar vivas)")
        }

        absences.append("não invente grafo/Arena/Autônomos neste pack de conversa")

        // WAVE-084: mid-thread empty editorial (never Home catalog).
        let empty = ConversationEmptyJudgment.packFacts(
            prompt: invite,
            suggestions: emptySuggestions,
            isHomePartida: false
        )
        facts.append(contentsOf: empty.facts)
        absences.append(contentsOf: empty.absences)

        // WAVE-106: hydrate organs from published model slice when bound.
        let bubble = published?.presenceBubble
        let queued = published?.queued ?? []
        let agents = published?.agents
            ?? bubble?.agents
            ?? []
        let decisionRequired = bubble.map {
            ConversationDecisionJudgment.isDecisionRequired($0)
        } ?? false
        let decisionTitles = bubble.map {
            ConversationDecisionJudgment.choiceActions(for: $0).map(\.title)
        } ?? []
        let hasPlan = bubble?.executionPlan != nil
            || bubble?.executionProgress != nil

        if published == nil {
            absences.append("model mid-thread ainda não hidratado neste pack (session-only)")
        }

        // WAVE-095: can_do matrix + wire organ packFacts (never ongoing-bool alone).
        let canSignals = ConversationCanDoJudgment.liveSignals(
            matchingLive: matchingLive,
            decisionRequired: decisionRequired,
            decisionActionTitles: decisionTitles,
            queueCount: queued.count,
            hasPlan: hasPlan,
            laneCount: agents.count
        )
        let canDoPack = ConversationCanDoJudgment.packFacts(canSignals)
        facts.append(contentsOf: canDoPack.facts)
        absences.append(contentsOf: canDoPack.absences)

        // Decision — prefer bubble pack when available.
        if let bubble {
            let decisionPack = ConversationDecisionJudgment.packFacts(from: bubble)
            facts.append(contentsOf: decisionPack.facts)
            absences.append(contentsOf: decisionPack.absences)
        } else {
            let decisionPack = ConversationDecisionJudgment.packFacts(
                decisionRequired: canSignals.hasDecision,
                actionTitles: canSignals.decisionActionTitles
            )
            facts.append(contentsOf: decisionPack.facts)
            absences.append(contentsOf: decisionPack.absences)
        }

        let queuePack = ComposerQueueJudgment.packFacts(from: queued)
        facts.append(contentsOf: queuePack.facts)
        absences.append(contentsOf: queuePack.absences)

        let planPack = PlanJudgment.packFacts(
            plan: bubble?.executionPlan,
            progress: bubble?.executionProgress
        )
        facts.append(contentsOf: planPack.facts)
        absences.append(contentsOf: planPack.absences)

        let lanesPack = ConversationAgentLanesJudgment.packFacts(from: agents)
        facts.append(contentsOf: lanesPack.facts)
        absences.append(contentsOf: lanesPack.absences)

        let stripFace: ConversationExecutionFace
        if let bubble {
            stripFace = ConversationExecutionPhase.face(for: bubble)
        } else {
            stripFace = matchingLive.first.map { ConversationExecutionPhase.face(for: $0) } ?? .quiet
        }
        let stripPack = ConversationLiveStripJudgment.packFacts(
            decisionRequired: canSignals.hasDecision,
            choiceActionCount: canSignals.decisionActionTitles.count,
            hasSteerHandler: canSignals.hasRunning || canSignals.hasPaused,
            face: stripFace,
            showsStop: bubble.map { ConversationExecutionPhase.stripShowsLiveChrome($0) }
                ?? (stripFace != .finished && stripFace != .quiet)
        )
        facts.append(contentsOf: stripPack.facts)
        absences.append(contentsOf: stripPack.absences)

        // WAVE-160: steer organ — wire hollow packFacts when presence has trace.
        if let traceId = bubble?.traceId {
            let steerPack = ConversationSteerJudgment.packFacts(
                instruction: "",
                scope: .currentStep,
                last: published?.lastSteerReceipt,
                traceId: traceId
            )
            facts.append(contentsOf: steerPack.facts)
            absences.append(contentsOf: steerPack.absences)
            absences.append("steer draft sheet-local — pack sem instrução até o modal")
        } else if canSignals.hasRunning || canSignals.hasPaused {
            absences.append("steer: sem traceId no presence bubble — não invente recibo")
        }

        // WAVE-161: surface handoff organ (iPhone↔Mac continuity face).
        let handoffPack = ConversationHandoffJudgment.packFacts(
            from: published?.latestSurfaceHandoff
        )
        facts.append(contentsOf: handoffPack.facts)
        absences.append(contentsOf: handoffPack.absences)

        // WAVE-163: change-review organs when presence trace has review slice.
        if bubble?.traceId != nil {
            let sheetPack = ChangeReviewSheetJudgment.packFacts(
                loadFinished: published?.changeReviewLoadFinished ?? false,
                review: published?.changeReview
            )
            facts.append(contentsOf: sheetPack.facts)
            absences.append(contentsOf: sheetPack.absences)
            let riskPack = ChangeReviewJudgment.packFacts(from: published?.changeReview)
            facts.append(contentsOf: riskPack.facts)
            absences.append(contentsOf: riskPack.absences)
        }

        // WAVE-164: composer draft · effort · stale-read · artifacts list.
        if let published {
            let draftPack = ComposerDraftJudgment.packFacts(
                drafts: published.drafts,
                uploadPercent: published.uploadPercent
            )
            facts.append(contentsOf: draftPack.facts)
            absences.append(contentsOf: draftPack.absences)
            let effortPack = ComposerEffortJudgment.packFacts(effort: published.effort)
            facts.append(contentsOf: effortPack.facts)
            absences.append(contentsOf: effortPack.absences)
            let stalePack = ConversationStaleReadJudgment.packFacts(
                capturedAt: published.cacheCapturedAt
            )
            facts.append(contentsOf: stalePack.facts)
            absences.append(contentsOf: stalePack.absences)
            let artifactPack = ArtifactListJudgment.packFacts(
                items: published.artifacts,
                selectedID: nil
            )
            facts.append(contentsOf: artifactPack.facts)
            absences.append(contentsOf: artifactPack.absences)
        }

        // WAVE-165: execution proof + editorial signature organs.
        if let bubble {
            let proofPack = ExecutionProofJudgment.packFacts(
                bubble: bubble,
                artifactItems: published?.artifacts ?? []
            )
            facts.append(contentsOf: proofPack.facts)
            absences.append(contentsOf: proofPack.absences)
            let editorialPack = EditorialTurnJudgment.packFacts(
                provider: bubble.provider,
                model: bubble.model,
                elapsedMs: bubble.elapsedMs,
                feedbackAction: nil
            )
            facts.append(contentsOf: editorialPack.facts)
            absences.append(contentsOf: editorialPack.absences)
        }

        // WAVE-166: outline + composer toolbar organs.
        if let published {
            let outlinePack = ConversationOutlineJudgment.packFacts(turnCount: published.turnCount)
            facts.append(contentsOf: outlinePack.facts)
            absences.append(contentsOf: outlinePack.absences)
            let toolbarPack = ComposerToolbarJudgment.packFacts(
                mode: published.toolbarMode,
                workspaceName: published.toolbarWorkspaceName,
                effort: published.effort
            )
            facts.append(contentsOf: toolbarPack.facts)
            absences.append(contentsOf: toolbarPack.absences)
        }

        let surface: String
        if workspaceKey != nil {
            surface = "conversation.workspace"
        } else {
            surface = "conversation"
        }

        return AgenticOccasionPack(
            surface: surface,
            subject: subject,
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: canDoPack.canDo
        ).render()
    }

    /// Shared live-anchor line for Home/Workspace packs (face product words).
    static func liveAnchorLine(_ session: LiveSessionSnapshot) -> String {
        let face = ConversationExecutionPhase.face(for: session)
        let product = ConversationExecutionPhase.primaryProduct(face)
        return "live · \(session.title) · \(product)"
    }
}
