import SwiftUI
import AtlasCore

/// Autônomos — área própria 24/7 (canon da obra), independente de conversa.
/// Cada valor desta tela vem do loop real: área, lock, ciclos, backlog, frota
/// global, saúde da fila e recibos governados. Nada é inferido; ausência de
/// dado é ausência na tela (C13: estado só aparece com a prova correspondente).
struct AutonomosView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var control: AtlasAutonomosRunAction?
    @State private var startRunMode: AtlasAutonomosStartRunMode?
    @State private var showTransferSheet = false
    @State private var detailSheet: AutonomosDetailSheet?
    @State private var nightly = NightlyProposalController.shared
    @State private var nightlyStartProposal: NightlyProposalController.ProposalPayload?
    @State private var selfConstructionReceipt: SelfConstructionReceipt?
    @State var rhythmSampleDays: Int?

    var model: AutonomosModel { session.autonomos }

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                AutonomosViewHeader(
                    auditModeEnabled: session.auditModeEnabled,
                    canRefresh: model.selectedArea != nil,
                    isHealthy: isHeaderHealthy,
                    reduceMotion: reduceMotion,
                    onBack: { dismiss() },
                    onRefresh: { Task { await model.refreshSelected() } }
                )
                content
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
                    .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
            }
        }
        .navigationBarHidden(true)
        .accessibilityIdentifier(A11yID.autonomosScreen)
        .accessibilityLabel(spokenScreenLabel())
        .accessibilityHint(Self.screenHint)
        .task { if case .idle = model.phase { await model.load() } }
        .task { await refreshRhythmLearning() }
        .autonomosSheets(
            model: model,
            nightly: nightly,
            control: $control,
            startRunMode: $startRunMode,
            nightlyStartProposal: $nightlyStartProposal,
            showTransferSheet: $showTransferSheet,
            detailSheet: $detailSheet,
            selfConstructionReceipt: $selfConstructionReceipt,
            canRevert: canRevertSelfConstruction,
            revertReceipt: revertReceipt
        )
    }

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .idle, .loading:
            AutonomosPreludeBlocks(nightly: nightly, rhythmSampleDays: rhythmSampleDays) { nightlyStartProposal = $0 }
            Spacer()
            TraceEvidenceLoading(text: "consultando a frota…", reduceMotion: reduceMotion)
            Spacer()
        case .failed(let message):
            AutonomosPreludeBlocks(nightly: nightly, rhythmSampleDays: rhythmSampleDays) { nightlyStartProposal = $0 }
            Spacer()
            AutonomosFleetFailureEmpty(message: message) { Task { await model.load() } }
            Spacer()
        case .loaded:
            AutonomosLoadedSection(
                model: model,
                auditModeEnabled: session.auditModeEnabled,
                nightly: nightly,
                rhythmSampleDays: rhythmSampleDays,
                oldestBacklogCreatedAt: oldestBacklogCreatedAt(),
                nightlyStartProposal: $nightlyStartProposal,
                control: $control,
                startRunMode: $startRunMode,
                showTransferSheet: $showTransferSheet,
                detailSheet: $detailSheet,
                selfConstructionReceipt: $selfConstructionReceipt,
                onRefreshRhythm: { await refreshRhythmLearning() }
            )
        }
    }
}
