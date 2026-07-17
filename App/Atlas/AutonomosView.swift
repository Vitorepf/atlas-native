import SwiftUI
import AtlasCore

/// Autônomos — área própria 24/7 (canon da obra), independente de conversa.
/// Cada valor desta tela vem do loop real: área, lock, ciclos, backlog, frota
/// global, saúde da fila e recibos governados. Nada é inferido; ausência de
/// dado é ausência na tela (C13: estado só aparece com a prova correspondente).
struct AutonomosView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
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
                nightlyProposal(proposal)
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 10)
            }
            rhythmLearningLine
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
                nightlyProposal(proposal)
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 10)
            }
            rhythmLearningLine
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
                        nightlyProposal(proposal)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    rhythmLearningLine
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
                    awaitingYouSection
                    areaPicker
                    if let area = model.selectedArea { areaDetail(area) }
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
                        AutonomosFleetSection(fleet: fleet, auditModeEnabled: session.auditModeEnabled)
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

    private func nightlyProposal(_ proposal: NightlyProposalController.ProposalPayload) -> some View {
        NightlyProposalCard(
            proposal: proposal,
            onAccept: { nightlyStartProposal = proposal },
            onDismiss: { nightly.dismissProposal() },
            onMute: { nightly.muteProposal(days: $0) }
        )
    }

    @ViewBuilder
    private var rhythmLearningLine: some View {
        if let sampleDays = rhythmSampleDays, sampleDays < 4 {
            Text("aprendendo seu ritmo · dia \(max(1, sampleDays)) de 4")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("aprendendo seu ritmo, dia \(max(1, sampleDays)) de 4")
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

    // MARK: - Aguarda operador (M139)

    @ViewBuilder
    private var awaitingYouSection: some View {
        let inbox = model.backlog?.inboxItems.filter(\.decisionRequired) ?? []
        let workOrders = model.backlog?.workOrders.filter(\.operatorDecisionRequired) ?? []
        let count = inbox.count + workOrders.count
        if count > 0 {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    AutonomosChrome.sectionCaption("AGUARDANDO VOCÊ")
                    Spacer()
                    Text("\(count)")
                        .font(AtlasFont.mono(13))
                        .foregroundStyle(AtlasTheme.domOperacional)
                        .contentTransition(.numericText())
                }
                Text("Há decisão pública pendente; nada aqui afirma execução antes do recibo do owner.")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                HStack(spacing: 8) {
                    if !inbox.isEmpty {
                        detailButton("inbox \(inbox.count)", .inbox)
                    }
                    if !workOrders.isEmpty {
                        detailButton("ordens \(workOrders.count)", .workOrders)
                    }
                    if model.backlog?.findings.returned ?? 0 > 0 {
                        detailButton("findings", .findings)
                    }
                    detailButton("budgets", .budgets)
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.domOperacional.opacity(0.08)))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.domOperacional.opacity(0.38), lineWidth: 1))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("aguardando você, \(count) decisões")
            .accessibilityIdentifier(A11yID.autonomosAwaitingYou)
        }
    }

    private func detailButton(_ label: String, _ kind: AutonomosDetailSheet) -> some View {
        Button { detailSheet = kind } label: {
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(Capsule().fill(AtlasTheme.surfaceHi))
                .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("abrir detalhes de \(label)")
        .accessibilityIdentifier(A11yID.autonomosDetailButton(kind.id))
    }

    // MARK: - Instâncias (áreas)

    private var areaPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            AutonomosChrome.sectionCaption("INSTÂNCIAS")
            ForEach(model.areas) { area in
                Button {
                    Task { await model.selectArea(area.id) }
                } label: {
                    HStack(spacing: 10) {
                        Circle().fill(areaStateColor(area)).frame(width: 8, height: 8)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(area.areaName).font(.system(.footnote, weight: .semibold))
                                .foregroundStyle(AtlasTheme.textPrimary)
                            Text(area.objective).font(.caption).foregroundStyle(AtlasTheme.textTertiary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Text(areaStateLabel(area)).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(area.id == model.selectedAreaID ? AtlasTheme.surfaceHi : AtlasTheme.surface))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(area.id == model.selectedAreaID ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func areaDetail(_ area: AtlasAutonomosArea) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(area.areaName).font(AtlasFont.serif(24, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    Text(area.focus).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                }
                Spacer()
                Text("tier \(area.autonomyTier)/\(area.maxTierForArea)")
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
            }
            Text(area.objective).font(.footnote).foregroundStyle(AtlasTheme.textSecondary).fixedSize(horizontal: false, vertical: true)
            Divider().overlay(AtlasTheme.separatorSoft)
            HStack(spacing: 12) {
                DetailMetric(label: "ciclos", value: "\(model.cycles?.ledgerRecordCountTotal ?? 0)")
                DetailMetric(label: "tarefas", value: "\(model.backlog?.workOrders.count ?? 0)")
                DetailMetric(label: "inbox", value: "\(model.backlog?.inboxItems.count ?? 0)")
            }
            backlogDetailShortcuts
            placementSection
            deliveredSection(for: area)
            if !area.ownedSystems.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("SISTEMAS SOB RESPONSABILIDADE").font(AtlasFont.mono(10)).tracking(0.9).foregroundStyle(AtlasTheme.textTertiary)
                    Text(area.ownedSystems.joined(separator: " · ")).font(.caption).foregroundStyle(AtlasTheme.textSecondary)
                }
            }
            controls(for: area)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(AtlasTheme.surface))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AtlasTheme.separator, lineWidth: 1))
    }

    @ViewBuilder
    private var backlogDetailShortcuts: some View {
        if let backlog = model.backlog {
            VStack(alignment: .leading, spacing: 7) {
                Text("DETALHES PÚBLICOS")
                    .font(AtlasFont.mono(10)).tracking(0.9)
                    .foregroundStyle(AtlasTheme.textTertiary)
                HStack(spacing: 8) {
                    detailButton("workOrders \(backlog.workOrders.count)", .workOrders)
                    detailButton("inbox \(backlog.inboxItems.count)", .inbox)
                    detailButton("findings \(backlog.findings.returned)", .findings)
                    detailButton("budgets", .budgets)
                }
            }
        }
    }

    /// C13: placement é só o rótulo verificado do lock real — campo ausente
    /// permanece ausente, sem fallback visual.
    @ViewBuilder
    private var placementSection: some View {
        if let p = model.live?.runtimePlacement,
           p.host != nil || p.workspace != nil || p.repository != nil {
            VStack(alignment: .leading, spacing: 5) {
                Text("ONDE ESTÁ RODANDO").font(AtlasFont.mono(10)).tracking(0.9)
                    .foregroundStyle(AtlasTheme.textTertiary)
                HStack(spacing: 8) {
                    if let host = p.host { AutonomosChrome.tag(host) }
                    if let env = p.environment { AutonomosChrome.tag(env) }
                    if let ws = p.workspace { AutonomosChrome.tag(ws) }
                    if let repo = p.repository { AutonomosChrome.tag(repo) }
                    if let branch = p.branch { AutonomosChrome.tag(branch) }
                    if let ttl = p.leaseTTLSeconds { AutonomosChrome.tag("lease \(ttl)s") }
                }
            }
        }
    }

    /// C13: somente ciclos com merge comprovado (outcome=merged + hash real).
    @ViewBuilder
    private func deliveredSection(for area: AtlasAutonomosArea) -> some View {
        if let delivered = model.delivered, delivered.deliveredTotal > 0 {
            let isSelf = isSelfConstructionArea(area)
            VStack(alignment: .leading, spacing: 6) {
                Text(isSelf ? "O ATLAS MELHOROU O PRÓPRIO APP" : "ENTREGAS COMPROVADAS · \(delivered.deliveredTotal)")
                    .font(AtlasFont.mono(10)).tracking(0.9)
                    .foregroundStyle(isSelf ? AtlasTheme.domAutonomos : AtlasTheme.accent)
                ForEach(delivered.delivered.prefix(3)) { cycle in
                    if isSelf {
                        Button {
                            selfConstructionReceipt = SelfConstructionReceipt(
                                cycle: cycle,
                                finding: selfConstructionFinding
                            )
                        } label: {
                            deliveredRow(cycle)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("recibo de auto-construção, ciclo \(cycle.cycleIndex), merge \(String(cycle.mergeHash.prefix(8)))")
                    } else {
                        if let repo = area.repositoryNames.first?.nonEmpty {
                            Button {
                                openCommit(cycle.mergeHash, repo: repo)
                            } label: {
                                deliveredRow(cycle, graphHint: true)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("abrir merge \(String(cycle.mergeHash.prefix(8))) no grafo de \(repo)")
                        } else {
                            deliveredRow(cycle)
                        }
                    }
                }
            }
        }
    }

    private func deliveredRow(_ cycle: AtlasAutonomosCycle, graphHint: Bool = false) -> some View {
        HStack(spacing: 8) {
            Text("ciclo \(cycle.cycleIndex)").font(.caption).foregroundStyle(AtlasTheme.textSecondary)
            Text(String(cycle.mergeHash.prefix(8))).font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
            if graphHint {
                Image(systemName: "point.3.connected.trianglepath.dotted")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AtlasTheme.accent)
            }
            Spacer()
            Text(cycle.recordedAt).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
        }
        .contentShape(Rectangle())
    }

    private func openCommit(_ hash: String, repo: String) {
        guard let url = URL(string: "atlas://code/\(repo)?commit=\(hash)") else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        openURL(url)
    }

    private func isSelfConstructionArea(_ area: AtlasAutonomosArea) -> Bool {
        area.repositoryNames.contains("atlas-native")
    }

    private var selfConstructionFinding: AtlasAutonomosFinding? {
        model.backlog?.findings.items.first {
            $0.source == "native_constitution_scan"
                && (($0.ruleId?.isEmpty == false) || ($0.ruleText?.isEmpty == false))
        }
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

    /// C13: disponibilidade vem de canControlSelectedArea (POSTs existem e são
    /// governados) — nunca de live.readOnly, que descreve apenas o GET.
    private func controls(for area: AtlasAutonomosArea) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                if model.live?.isPaused == true {
                    Button("Retomar") { control = .resume }.buttonStyle(AutonomosPrimaryButtonStyle())
                } else {
                    Button("Pausar") { control = .pause }.buttonStyle(AutonomosSecondaryButtonStyle())
                }
                Button("Transferir") { showTransferSheet = true }.buttonStyle(AutonomosSecondaryButtonStyle())
                Button("Encerrar") { control = .kill }.buttonStyle(AutonomosDestructiveButtonStyle())
            }
            HStack(spacing: 8) {
                Button("Novo ciclo · ensaio") { startRunMode = .dryRun }
                    .buttonStyle(AutonomosPrimaryButtonStyle())
                Button("Executar de verdade") { startRunMode = .execute }
                    .buttonStyle(AutonomosSecondaryButtonStyle())
            }
        }
        .disabled(!model.canControlSelectedArea)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("controles da instância \(area.areaName)")
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

    // C13: fase canônica do Core (terminated > paused > running > idle) —
    // a View não relê nem reinterpreta run_state cru.
    private func areaStateLabel(_ area: AtlasAutonomosArea) -> String {
        switch area.loopStatus.phase {
        case .terminated: return "encerrada"
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "sem lease"
        }
    }

    private func areaStateColor(_ area: AtlasAutonomosArea) -> Color {
        switch area.loopStatus.phase {
        case .terminated: return AtlasTheme.domOperacional
        case .paused: return AtlasTheme.accent
        case .running: return AtlasTheme.domAutonomos
        case .idle: return AtlasTheme.textTertiary
        }
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
