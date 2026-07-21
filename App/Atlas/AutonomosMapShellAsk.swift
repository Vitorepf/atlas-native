import SwiftUI
import AtlasCore

// IDLE-COMPRESS peel ask dock from AutonomosMapShell (canon §7 · density ≤400)

extension AutonomosMapShell {
    var askPillDock: some View {
        AgenticAskDock {
            AgenticPill(
                invite: AutonomosAskContext.invite(destination: destination, vestment: vestmentForAsk),
                accessibilityId: A11yID.autonomosAskPill
            ) {
                showingAsk = true
            }
        }
    }

    var askConversationSheet: some View {
        ConversationView(
            client: session.client,
            threadId: askThreadId,
            title: selectedUnit?.name ?? "Autônomos",
            emptyPrompt: AutonomosAskContext.invite(destination: destination, vestment: vestmentForAsk),
            emptySuggestions: AutonomosAskContext.emptySuggestions(destination: destination),
            taskKind: "autonomos",
            workspace: nil,
            draft: "",
            turnFacts: { [selectedUnit, destination, model, nightly] _ in
                let n = nightly
                // WAVE-177: same windows load as RhythmLearningLine face (no invent).
                let rhythmWindows = await AtlasSession.rhythm.windows(minimumDays: 4)
                return AutonomosAskContext.facts(
                    unit: selectedUnit,
                    destination: destination,
                    backlog: model.backlog,
                    controlFace: AutonomosRunControlJudgment.face(
                        areaSelected: model.selectedArea != nil,
                        canControl: model.canControlSelectedArea,
                        live: model.live
                    ),
                    canControl: model.canControlSelectedArea,
                    live: model.live,
                    lastControlReceipt: model.lastControlReceipt,
                    delivered: model.delivered,
                    cycles: model.cycles,
                    lastTransferReceipt: model.lastTransferReceipt,
                    taskHealth: model.taskHealth,
                    areaSelected: model.selectedArea != nil,
                    fleet: model.fleet,
                    digest: model.digest,
                    areas: model.areas,
                    selectedAreaID: model.selectedAreaID,
                    // WAVE-159: veto + nightly pack organs.
                    selfConstructionReceipt: latestMergeProvedReceipt,
                    nightlyPending: n.pendingProposal != nil,
                    nightlyMuted: n.isProposalMuted,
                    nightlyAutoPaused: AtlasSession.nightlyProposalAutoPaused(),
                    nightlyWorkspaceText: n.pendingProposal?.workspaceText,
                    nightlyMutedUntil: n.mutedUntil,
                    rhythmWindows: rhythmWindows
                )
            },
            onThread: { askThreadId = $0 },
            hidesNavigationBack: true
        )
        .agenticAskSheetPresentation()
    }
}
