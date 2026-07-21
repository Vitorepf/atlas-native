import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: ConversationOccasionPack + Live + Organs fused

// MARK: - Conversation mid-thread occasion (WAVE-029)
// WAVE-171 density peel — host (slice + shell); Live/Organs peels.

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
        /// WAVE-178: send readiness (draft text + sending flag).
        var draftText: String = ""
        var isSending: Bool = false
        var artifacts: [AtlasTraceArtifacts.Item] = []
        /// WAVE-170: full artifacts bag when published for ArtifactJudgment.
        var artifactsBag: AtlasTraceArtifacts? = nil
        /// WAVE-166: outline turn count + toolbar chrome.
        var turnCount: Int = 0
        var toolbarMode: String = ""
        var toolbarWorkspaceName: String? = nil
        /// WAVE-168: messages load fail + presence + workspace catalog count.
        var hasLoadError: Bool = false
        var workspaceCatalogCount: Int = 0

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

        // WAVE-185: thread shell identity (one law).
        let shell = ConversationThreadShellJudgment.packFacts(
            session: session,
            threadId: threadId,
            title: title,
            workspaceKey: workspaceKey
        )
        facts.append(contentsOf: shell.facts)
        absences.append(contentsOf: shell.absences)
        let subject = shell.subject

        let matchingLive = appendLiveSessionFacts(
            session: session,
            threadId: threadId,
            into: &facts,
            anchors: &anchors,
            absences: &absences
        )

        // WAVE-084: mid-thread empty editorial (never Home catalog).
        let empty = ConversationEmptyJudgment.packFacts(
            prompt: invite,
            suggestions: emptySuggestions,
            isHomePartida: false
        )
        facts.append(contentsOf: empty.facts)
        absences.append(contentsOf: empty.absences)

        let canDo = appendLiveOrgans(
            published: published,
            matchingLive: matchingLive,
            into: &facts,
            absences: &absences
        )

        appendSteerHandoffReviewOrgans(
            published: published,
            matchingLive: matchingLive,
            into: &facts,
            absences: &absences
        )
        appendComposerEvidenceOrgans(
            published: published,
            matchingLive: matchingLive,
            into: &facts,
            absences: &absences
        )

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
            canDo: canDo
        ).render()
    }

    /// Shared live-anchor line for Home/Workspace packs (face product words).
    static func liveAnchorLine(_ session: LiveSessionSnapshot) -> String {
        let face = ConversationExecutionPhase.face(for: session)
        let product = ConversationExecutionPhase.primaryProduct(face)
        return "live · \(session.title) · \(product)"
    }
}
extension ConversationOccasionPack {
    /// Matching live sessions + hub count. Returns matching list for later organs.
    @MainActor
    // MARK: - Live sessions
    static func appendLiveSessionFacts(
        session: AtlasSession,
        threadId: ThreadID,
        into facts: inout [String],
        anchors: inout [String],
        absences: inout [String]
    ) -> [LiveSessionSnapshot] {
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
                if !s.phaseTitle.isEmpty {
                    facts.append("live_detail · \(s.title) · \(s.phaseTitle)")
                }
            }
        }
        let hubLive = TurnPresence.shared.liveSessions.count
        if hubLive > matchingLive.count {
            facts.append("sessoes_vivas_hub_global: \(hubLive) (outras conversas podem estar vivas)")
        }
        return matchingLive
    }

    /// Can-do · decision · queue · plan · lanes · strip. Returns canDo for render.
    @MainActor
    // MARK: - Live organs (can_do · strip)
    static func appendLiveOrgans(
        published: PublishedSlice?,
        matchingLive: [LiveSessionSnapshot],
        into facts: inout [String],
        absences: inout [String]
    ) -> AgenticOccasionPack.CanDo {
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

        let hasReviewControl = ChangeReviewControlJudgment.hasPublishedControlActions(
            from: published?.changeReview
        )
        let canSignals = ConversationCanDoJudgment.liveSignals(
            matchingLive: matchingLive,
            decisionRequired: decisionRequired,
            decisionActionTitles: decisionTitles,
            queueCount: queued.count,
            hasPlan: hasPlan,
            laneCount: agents.count,
            hasReviewControl: hasReviewControl
        )
        let canDoPack = ConversationCanDoJudgment.packFacts(canSignals)
        facts.append(contentsOf: canDoPack.facts)
        absences.append(contentsOf: canDoPack.absences)

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

        // WAVE-180: StateCard kind pack (strip phase alone is not enough).
        let statePack = ExecutionStateCardJudgment.packFacts(
            state: bubble?.executionPresentationState
        )
        facts.append(contentsOf: statePack.facts)
        absences.append(contentsOf: statePack.absences)

        // WAVE-174: timeline narrative + filter open recorte (chip filter is UI-local).
        let activities = bubble?.activities ?? []
        let narrativePack = LiveTimelineNarrativeJudgment.packFacts(from: activities)
        facts.append(contentsOf: narrativePack.facts)
        absences.append(contentsOf: narrativePack.absences)
        let filterPack = LiveTimelineFilterJudgment.packFactsOpenRecorte(
            totalSteps: activities.count
        )
        facts.append(contentsOf: filterPack.facts)
        absences.append(contentsOf: filterPack.absences)

        // Steer needs canSignals flags — keep here.
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

        return canDoPack.canDo
    }
}
extension ConversationOccasionPack {
    @MainActor
    // MARK: - Handoff · review · proof
    static func appendSteerHandoffReviewOrgans(
        published: PublishedSlice?,
        matchingLive: [LiveSessionSnapshot],
        into facts: inout [String],
        absences: inout [String]
    ) {
        let bubble = published?.presenceBubble

        let handoffPack = ConversationHandoffJudgment.packFacts(
            from: published?.latestSurfaceHandoff
        )
        facts.append(contentsOf: handoffPack.facts)
        absences.append(contentsOf: handoffPack.absences)

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
            // WAVE-175: assinatura run/file — availableActions · undecided · never NL apply.
            let controlPack = ChangeReviewControlJudgment.packFacts(
                from: published?.changeReview
            )
            facts.append(contentsOf: controlPack.facts)
            absences.append(contentsOf: controlPack.absences)
        }

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
            // WAVE-174: structured markdown kinds from presence text (not full dump).
            let mdPack = AtlasMarkdownJudgment.packFacts(from: bubble.text)
            facts.append(contentsOf: mdPack.facts)
            absences.append(contentsOf: mdPack.absences)
        }
    }

    @MainActor
    // MARK: - Composer · evidence · messages
    static func appendComposerEvidenceOrgans(
        published: PublishedSlice?,
        matchingLive: [LiveSessionSnapshot],
        into facts: inout [String],
        absences: inout [String]
    ) {
        let bubble = published?.presenceBubble
        guard let published else { return }

        let draftPack = ComposerDraftJudgment.packFacts(
            drafts: published.drafts,
            uploadPercent: published.uploadPercent
        )
        facts.append(contentsOf: draftPack.facts)
        absences.append(contentsOf: draftPack.absences)
        // WAVE-178: gold CTA send face ≡ pack (never invent allows).
        let liveBubblePresent = bubble.map {
            ConversationExecutionPhase.stripShowsLiveChrome($0)
        } ?? false
        let sendPack = ComposerSendJudgment.packFacts(
            draftText: published.draftText,
            drafts: published.drafts,
            isSending: published.isSending,
            liveBubblePresent: liveBubblePresent
        )
        facts.append(contentsOf: sendPack.facts)
        absences.append(contentsOf: sendPack.absences)
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
        let artFacePack = ArtifactJudgment.packFacts(
            artifacts: published.artifactsBag,
            deliveryChecks: []
        )
        facts.append(contentsOf: artFacePack.facts)
        absences.append(contentsOf: artFacePack.absences)
        let evidencePack = TraceEvidenceJudgment.packFacts(
            isLoading: published.artifactsBag == nil && bubble?.traceId != nil,
            reason: published.artifactsBag == nil ? "artifacts_bag_nil" : nil
        )
        facts.append(contentsOf: evidencePack.facts)
        absences.append(contentsOf: evidencePack.absences)
        if !published.artifacts.isEmpty {
            let previewPack = ArtifactPreviewJudgment.packFacts(
                preview: .idle,
                selected: nil
            )
            facts.append(contentsOf: previewPack.facts)
            absences.append(contentsOf: previewPack.absences)
            absences.append("artifact_preview: face-only — seleção só no sheet de artefatos")
        }

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

        let messagesPack = ConversationMessagesJudgment.packFacts(
            hasLoadError: published.hasLoadError,
            turnCount: published.turnCount
        )
        facts.append(contentsOf: messagesPack.facts)
        absences.append(contentsOf: messagesPack.absences)
        let presencePack = TurnPresenceJudgment.packFacts(
            presence: bubble?.executionPresence,
            liveSessionCount: matchingLive.count
        )
        facts.append(contentsOf: presencePack.facts)
        absences.append(contentsOf: presencePack.absences)
        let sheetPack = ComposerSheetJudgment.packFacts(
            modeKey: published.toolbarMode.isEmpty ? nil : published.toolbarMode,
            workspaceCount: published.workspaceCatalogCount,
            currentWorkspace: published.toolbarWorkspaceName
        )
        facts.append(contentsOf: sheetPack.facts)
        absences.append(contentsOf: sheetPack.absences)
    }
}
