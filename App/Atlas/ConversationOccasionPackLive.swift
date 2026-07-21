import Foundation
import AtlasCore

// WAVE-171 density peel — conversation pack live organs (session live + can_do + strip)

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
