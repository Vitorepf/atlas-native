import Foundation
import AtlasCore

// WAVE-171 density peel — conversation pack residual organs
// (handoff · review · composer · proof · outline · messages)

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
