import SwiftUI
import AtlasCore

/// Autônomos — área própria 24/7 (canon da obra), independente de conversa.
/// Cada valor desta tela vem do loop real: área, lock, ciclos, backlog, frota
/// global, saúde da fila e recibos governados. Nada é inferido; ausência de
/// dado é ausência na tela (C13: estado só aparece com a prova correspondente).
struct AutonomosView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var control: AtlasAutonomosRunAction?
    @State private var startRunMode: AtlasAutonomosStartRunMode?
    @State private var showTransferSheet = false
    @State private var detailSheet: AutonomosDetailSheet?
    @State private var nightly = NightlyProposalController.shared
    @State private var nightlyStartProposal: NightlyProposalController.ProposalPayload?
    @State private var selfConstructionReceipt: SelfConstructionReceipt?
    @State private var rhythmSampleDays: Int?

    private var model: AutonomosModel { session.autonomos }

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                AutonomosViewHeader(
                    auditModeEnabled: session.auditModeEnabled,
                    canRefresh: model.selectedArea != nil,
                    onBack: { dismiss() },
                    onRefresh: { Task { await model.refreshSelected() } }
                )
                content
            }
        }
        .navigationBarHidden(true)
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
            VStack(spacing: 14) {
                ProgressView().tint(AtlasTheme.accent)
                Text("consultando a frota…")
                    .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textTertiary)
            }
            Spacer()
        case .failed(let message):
            AutonomosPreludeBlocks(nightly: nightly, rhythmSampleDays: rhythmSampleDays) { nightlyStartProposal = $0 }
            Spacer()
            VStack(spacing: 14) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title2).foregroundStyle(AtlasTheme.domOperacional)
                Text("A frota está fora de alcance.")
                    .font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                Text(message).font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
                    .multilineTextAlignment(.center)
                Button("Tentar de novo") { Task { await model.load() } }
                    .buttonStyle(AutonomosPrimaryButtonStyle())
            }
            .padding(32)
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

    private func refreshRhythmLearning() async {
        let windows = await AtlasSession.rhythm.windows(minimumDays: 4)
        rhythmSampleDays = windows.sampleDays
    }

    private func oldestBacklogCreatedAt() -> Date? {
        guard let backlog = model.backlog else { return nil }
        let values = backlog.workOrders.compactMap { AtlasTime.date($0.createdAt) }
            + backlog.inboxItems.compactMap { AtlasTime.date($0.createdAt) }
            + backlog.findings.items.compactMap { AtlasTime.date($0.createdAt) }
        return values.min()
    }

    private func canRevertSelfConstruction(_ receipt: SelfConstructionReceipt) -> Bool {
        model.canControlSelectedArea && receipt.cycle.mergeHash.nonEmpty != nil
    }

    private func revertReceipt(for receipt: SelfConstructionReceipt) -> AtlasAutonomosCycleRevertResponse? {
        guard let revert = model.lastRevertReceipt else { return nil }
        guard revert.revertOf.cycleIndex == receipt.cycle.cycleIndex,
              revert.revertOf.mergeHash == receipt.cycle.mergeHash else { return nil }
        return revert
    }
}
