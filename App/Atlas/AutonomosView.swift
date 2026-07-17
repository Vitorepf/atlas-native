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
                header
                content
            }
        }
        .navigationBarHidden(true)
        .task { if case .idle = model.phase { await model.load() } }
        .task { await refreshRhythmLearning() }
        .sheet(item: $control) { action in
            AutonomosControlSheet(action: action) { actor, reason in
                Task { await model.control(action, operatorActor: actor, reason: reason) }
            }
        }
        .sheet(item: $startRunMode) { mode in
            AutonomosStartRunSheet(mode: mode) { actor, reason in
                Task { await model.startRun(mode: mode, operatorActor: actor, operatorReason: reason) }
            }
        }
        .sheet(item: $nightlyStartProposal) { proposal in
            AutonomosReasonSheet(
                title: "Preparar missão noturna",
                explainer: "Ensaio (dry-run): a frota recebe a missão proposta e o recibo entra na fila; só o lease confirma execução.",
                reasonOptional: true,
                initialReason: proposal.prefilledReason
            ) { actor, reason in
                Task {
                    let previous = model.lastStartRunReceipt
                    await model.startRun(mode: .dryRun, operatorActor: actor, operatorReason: reason)
                    if model.lastStartRunReceipt != previous,
                       model.lastStartRunReceipt?.isEnqueued == true {
                        await nightly.accept(proposal)
                    }
                }
            }
        }
        .sheet(isPresented: $showTransferSheet) {
            AutonomosReasonSheet(title: "Transferir missão",
                                 explainer: "A fonte entrega a MESMA missão no próximo limite seguro; o alvo só existe quando reivindicar o lock.") { actor, reason in
                Task { await model.transfer(operatorActor: actor, reason: reason) }
            }
        }
        .sheet(item: $detailSheet) { sheet in
            AutonomosPublicDetailSheet(kind: sheet, backlog: model.backlog)
        }
        .sheet(item: $selfConstructionReceipt) { receipt in
            SelfConstructionReceiptSheet(
                receipt: receipt,
                canRevert: canRevertSelfConstruction(receipt),
                revertReceipt: revertReceipt(for: receipt)
            ) { actor, reason in
                Task {
                    await model.revertCycle(
                        cycle: String(receipt.cycle.cycleIndex),
                        operatorActor: actor,
                        reason: reason
                    )
                }
            }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AtlasTheme.surface))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Autônomos")
                    .font(AtlasFont.serif(21, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("ÁREA PRÓPRIA · 24/7")
                    .font(AtlasFont.mono(10)).tracking(1.2)
                    .foregroundStyle(AtlasTheme.accent)
                if session.auditModeEnabled {
                    Text("MODO AUDITORIA")
                        .font(AtlasFont.mono(9)).tracking(1.0)
                        .foregroundStyle(AtlasTheme.domOperacional)
                }
            }
            Spacer()
            Button { Task { await model.refreshSelected() } } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AtlasTheme.surface))
            }
            .disabled(model.selectedArea == nil)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, 8)
    }

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .idle, .loading:
            if let proposal = nightly.pendingProposal {
                AutonomosNightlyProposalBlock(
                    proposal: proposal,
                    onAccept: { nightlyStartProposal = proposal },
                    onDismiss: { nightly.dismissProposal() },
                    onMute: { nightly.muteProposal(days: $0) }
                )
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 10)
            }
            AutonomosRhythmLearningLine(sampleDays: rhythmSampleDays)
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 10)
            Spacer()
            VStack(spacing: 14) {
                ProgressView().tint(AtlasTheme.accent)
                Text("consultando a frota…")
                    .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textTertiary)
            }
            Spacer()
        case .failed(let message):
            if let proposal = nightly.pendingProposal {
                AutonomosNightlyProposalBlock(
                    proposal: proposal,
                    onAccept: { nightlyStartProposal = proposal },
                    onDismiss: { nightly.dismissProposal() },
                    onMute: { nightly.muteProposal(days: $0) }
                )
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 10)
            }
            AutonomosRhythmLearningLine(sampleDays: rhythmSampleDays)
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 10)
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
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    if let proposal = nightly.pendingProposal {
                        AutonomosNightlyProposalBlock(
                            proposal: proposal,
                            onAccept: { nightlyStartProposal = proposal },
                            onDismiss: { nightly.dismissProposal() },
                            onMute: { nightly.muteProposal(days: $0) }
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    AutonomosRhythmLearningLine(sampleDays: rhythmSampleDays)
                    if let fleet = model.fleet { AutonomosFleetSummary(fleet: fleet) }
                    if let digest = model.digest {
                        AutonomosNextDigestSection(digest: digest)
                    }
                    AutonomosOperationDigestSection(
                        deliveredTotal: model.delivered?.deliveredTotal ?? 0,
                        pendingCount: model.backlog?.workOrders.count ?? 0,
                        inboxCount: model.backlog?.inboxItems.count ?? 0,
                        incidentPresent: model.taskHealth?.incidents.present == true,
                        oldestBacklogCreatedAt: oldestBacklogCreatedAt(),
                        findingsByRisk: model.backlog?.findings.byRisk ?? [:]
                    )
                    AutonomosAwaitingYouSection(backlog: model.backlog) { detailSheet = $0 }
                    AutonomosAreaPicker(
                        areas: model.areas,
                        selectedAreaID: model.selectedAreaID
                    ) { id in
                        Task { await model.selectArea(id) }
                    }
                    if let area = model.selectedArea {
                        AutonomosAreaDetailSection(
                            area: area,
                            model: model,
                            control: $control,
                            startRunMode: $startRunMode,
                            showTransferSheet: $showTransferSheet,
                            onOpenDetail: { detailSheet = $0 },
                            onSelfConstructionReceipt: { selfConstructionReceipt = $0 }
                        )
                    }
                    if let receipt = model.lastStartRunReceipt, receipt.isEnqueued {
                        infoLine("Novo ciclo NA FILA — ainda não iniciado. A execução só é real quando o lease aparecer no vivo.")
                    }
                    if let transfer = model.lastTransferReceipt {
                        AutonomosTransferStatus(transfer: transfer) {
                            Task { await model.refreshTransferStatus() }
                        }
                    }
                    if let receipt = model.lastControlReceipt { controlReceipt(receipt) }
                    if let fleet = model.fleet {
                        AutonomosFleetSection(
                            fleet: fleet,
                            incidentPresent: model.taskHealth?.incidents.present == true,
                            auditModeEnabled: session.auditModeEnabled
                        )
                    }
                    if let health = model.taskHealth {
                        AutonomosTaskHealthSection(health: health)
                    }
                    if let history = model.fleetHistory, !history.events.isEmpty {
                        AutonomosFleetHistorySection(history: history)
                    }
                    if let error = model.controlError { errorCard(error) }
                }
                .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 10).padding(.bottom, 32)
            }
            .refreshable {
                await model.load()
                await refreshRhythmLearning()
            }
            .scrollIndicators(.hidden)
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

    private func controlReceipt(_ receipt: AtlasAutonomosRunControlResponse) -> some View {
        Text(receipt.note)
            .font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domAutonomos.opacity(0.1)))
    }

    private func infoLine(_ text: String) -> some View {
        Text(text)
            .font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .atlasCard(cornerRadius: 12)
    }

    private func errorCard(_ message: String) -> some View {
        Text(message).font(.footnote).foregroundStyle(AtlasTheme.domOperacional)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domOperacional.opacity(0.1)))
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
