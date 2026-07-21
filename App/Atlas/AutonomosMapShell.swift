import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: AutonomosMapShell routes/ask/catalog/actions/chrome fused

// MARK: - AutonomosMapShell

struct AutonomosMapShell: View {
    @Environment(AtlasSession.self) var session
    let model: AutonomosModel
    @Binding var destination: AutonomosDestination?
    @Binding var selectedUnitID: String?
    @Binding var showNewSheet: Bool
    @State var showingAsk = false
    @State var askThreadId: ThreadID?
    @State var confirmEnd = false
    @State var selfConstructionReceipt: SelfConstructionReceipt?
    @State var nightly = NightlyProposalController.shared
    @State var nightlyStartProposal: NightlyProposalController.ProposalPayload?
    @State var pendingRunControl: AutonomosRunControlAction?
    @State var showTransferSheet = false
    /// WAVE-065: multi-area bind chooser when N registered and unbound.
    @State var showAreaBindChooser = false

    var selectedUnit: AutonomosUnit? {
        guard let selectedUnitID else { return nil }
        return model.operatorUnit(id: selectedUnitID)
    }

    /// Mesma resolve do hub — ask e hub nunca divergem (WAVE-007).
    var organismVestment: AutonomosHubVestment {
        // WAVE-036: incidentPresent from published taskHealth (never invent).
        AutonomosHubVestment.resolve(
            backlog: model.backlog,
            live: model.live,
            incidentPresent: AutonomosTaskHealthJudgment.incidentPresent(model.taskHealth),
            unitPaused: selectedUnit?.paused ?? false
        )
    }

    var vestmentForAsk: AutonomosHubVestment { organismVestment }

    /// Só ciclos com merge real — nunca fabrica “melhorou”.
    var latestMergeProvedReceipt: SelfConstructionReceipt? {
        guard let cycles = model.delivered?.delivered else { return nil }
        guard let cycle = cycles.first(where: { $0.mergePerformed && !$0.mergeHash.isEmpty }) else {
            return nil
        }
        return SelfConstructionReceipt(cycle: cycle, finding: nil)
    }

    var body: some View {
        Group {
            if let destination {
                route(destination)
            } else {
                catalogFace
            }
        }
        .sheet(isPresented: $showNewSheet) {
            AutonomosNewSheet(
                onCreate: { name, charter in
                    let unit = model.createOperatorUnit(name: name, charter: charter)
                    showNewSheet = false
                    selectedUnitID = unit.id
                    destination = .hub
                },
                onCancel: { showNewSheet = false }
            )
        }
        .sheet(item: $selfConstructionReceipt) { receipt in
            // WAVE-033: wire veto-with-receipt when merge-proved + area controllable.
            SelfConstructionReceiptSheet(
                receipt: receipt,
                canRevert: SelfConstructionVetoJudgment.canRevert(
                    receipt: receipt,
                    canControlSelectedArea: model.canControlSelectedArea
                ),
                revertReceipt: model.lastRevertReceipt,
                controlError: model.controlError,
                onRevert: { actor, reason in
                    Task {
                        await model.revertCycle(
                            cycle: SelfConstructionVetoJudgment.cycleKey(for: receipt),
                            operatorActor: actor,
                            reason: reason
                        )
                    }
                }
            )
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
        .confirmationDialog("Encerrar este Autônomo?", isPresented: $confirmEnd, titleVisibility: .visible) {
            Button("Encerrar de vez", role: .destructive) { deleteSelected() }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Sai da sua lista. O motor no servidor ainda não liga a isto.")
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            askPillDock
        }
        .sheet(isPresented: $showingAsk) {
            askConversationSheet
        }
        .onAppear {
            #if DEBUG
            nightly.installDemoIfRequested()
            #endif
        }
        .task {
            await bindAreaIfNeeded()
        }
        .sheet(item: $pendingRunControl) { action in
            AutonomosReasonSheet(
                title: action.reasonSheetTitle,
                explainer: action.explainer,
                reasonOptional: action.reasonOptional
            ) { actor, reason in
                Task { await applyRunControl(action, actor: actor, reason: reason) }
            }
        }
        .sheet(isPresented: $showTransferSheet) {
            // WAVE-035: mission transfer handoff (server chooses target worker).
            AutonomosReasonSheet(
                title: AutonomosTransferJudgment.reasonTitle,
                explainer: AutonomosTransferJudgment.reasonExplainer,
                reasonOptional: false
            ) { actor, reason in
                Task {
                    await model.transfer(operatorActor: actor, reason: reason)
                    await model.refreshTransferStatus()
                }
            }
        }
        .sheet(isPresented: $showAreaBindChooser) {
            // WAVE-065: thin registered-area chooser (no monólito picker).
            AutonomosAreaBindChooser(
                areas: model.areas,
                onSelect: { id in
                    showAreaBindChooser = false
                    Task { await model.selectArea(id) }
                },
                onCancel: { showAreaBindChooser = false }
            )
        }
    }
}
// MARK: - AutonomosMapShellRoutes

extension AutonomosMapShell {
    @ViewBuilder
    func route(_ destination: AutonomosDestination) -> some View {
        switch destination {
        case .hub:
            if let unit = selectedUnit {
                AutonomosHubView(
                    unit: unit,
                    vestment: organismVestment,
                    controlFace: controlFace,
                    controlReceiptLine: controlReceiptLine,
                    evolutionMeta: AutonomosEvolutionJudgment.hubEvolutionMeta(
                        marcos: AutonomosEvolutionJudgment.marcos(
                            delivered: model.delivered,
                            cycles: model.cycles
                        ),
                        areaSelected: model.selectedArea != nil
                    ),
                    canTransfer: AutonomosTransferJudgment.canTransfer(
                        canControlSelectedArea: model.canControlSelectedArea
                    ),
                    transferReceiptLine: AutonomosTransferJudgment.receiptLine(model.lastTransferReceipt)
                        ?? model.controlError,
                    incidentMeta: AutonomosTaskHealthJudgment.hubIncidentMeta(health: model.taskHealth),
                    digestMeta: AutonomosDigestJudgment.hubMeta(from: model.digest),
                    needsAreaBind: areaBindFace.needsChooser,
                    registeredAreaCount: AutonomosAreaBindJudgment.registeredAreas(model.areas).count,
                    onChooseArea: { showAreaBindChooser = true },
                    onNavigate: { self.destination = $0 },
                    onControl: { pendingRunControl = $0 },
                    onTransfer: { showTransferSheet = true },
                    onLocalCatalogPause: { model.setOperatorUnitPaused(id: unit.id, paused: true) },
                    onLocalCatalogResume: { model.setOperatorUnitPaused(id: unit.id, paused: false) },
                    onEnd: { confirmEnd = true }
                )
            } else {
                missingUnit
            }
        case .evolution:
            AutonomosEvolutionView(
                unit: selectedUnit,
                areaSelected: model.selectedArea != nil,
                delivered: model.delivered,
                cycles: model.cycles,
                onOpenReceipt: { selfConstructionReceipt = $0 }
            )
        case .decisions, .decisionInbox, .decisionOrder:
            // WAVE-026: published backlog → decision surface; silence if empty.
            AutonomosDecisionSurface(
                model: model,
                destination: destination,
                onNavigate: { self.destination = $0 }
            )
        case .incident:
            // WAVE-036: task health → incident surface (published flags only).
            AutonomosIncidentSurface(
                areaSelected: model.selectedArea != nil,
                health: model.taskHealth
            )
        case .moment:
            // WAVE-038: scheduled digest window (provider-safe) — not invent.
            AutonomosDigestSurface(digest: model.digest)
        }
    }

    var missingUnit: some View {
        VStack(alignment: .leading, spacing: 12) {
            AutonomosMapChrome.heroTitle("Autônomo ausente", size: 26)
            Text("Volte à lista e abra de novo.")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .padding(AtlasTheme.Space.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    func deleteSelected() {
        guard let id = selectedUnitID else { return }
        model.removeOperatorUnit(id: id)
        selectedUnitID = nil
        destination = nil
    }
}
// MARK: - AutonomosMapShellAsk

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
// MARK: - AutonomosMapShellCatalog

extension AutonomosMapShell {
    /// Catálogo do operador + baseline Nightly/Ritmo (aprender-com-o-uso).
    var catalogFace: some View {
        VStack(spacing: 0) {
            if let receipt = latestMergeProvedReceipt {
                selfConstructionBanner(receipt)
            }
            VStack(alignment: .leading, spacing: 12) {
                AutonomosNightlyProposalBlock(nightly: nightly) { proposal in
                    nightlyStartProposal = proposal
                }
                AutonomosRhythmLearningLine()
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 10)
            .padding(.bottom, 4)

            // WAVE-037: thin fleet strip when global snapshot published (silence if nil).
            if let fleet = model.fleet {
                AutonomosFleetStrip(fleet: fleet, history: model.fleetHistory)
                    .padding(.bottom, 4)
            }

            AutonomosListView(
                units: model.operatorUnits,
                awaitingUnitIDs: AutonomosDecisionJudgment.awaitingUnitIDs(
                    units: model.operatorUnits,
                    backlog: model.backlog,
                    boundUnitID: selectedUnitID
                ),
                onOpen: { unit in
                    selectedUnitID = unit.id
                    destination = .hub
                },
                onCreate: { showNewSheet = true }
            )
        }
    }

    func selfConstructionBanner(_ receipt: SelfConstructionReceipt) -> some View {
        Button {
            selfConstructionReceipt = receipt
        } label: {
            HStack(spacing: 10) {
                Text("✦")
                    .font(AtlasFont.serif(14, .semibold))
                    .foregroundStyle(AtlasTheme.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("O Atlas melhorou o próprio app")
                        .font(AtlasFont.serif(15, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text("Merge comprovado · toque o recibo")
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 14)
            .background(AtlasTheme.surface.opacity(0.55))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AutonomosHubJudgment.selfBuildReceiptSpoken)
    }
}
// MARK: - AutonomosMapShellActions

extension AutonomosMapShell {
    var areaBindFace: AutonomosAreaBindFace {
        AutonomosAreaBindJudgment.face(
            areas: model.areas,
            selectedAreaID: model.selectedAreaID
        )
    }

    var controlFace: AutonomosRunControlFace {
        AutonomosRunControlJudgment.face(
            areaSelected: model.selectedArea != nil,
            canControl: model.canControlSelectedArea,
            live: model.live
        )
    }

    var controlReceiptLine: String? {
        AutonomosRunControlJudgment.receiptLine(
            receipt: model.lastControlReceipt,
            startReceipt: model.lastStartRunReceipt,
            error: model.controlError
        )
    }

    func bindAreaIfNeeded() async {
        if model.areas.isEmpty {
            await model.load()
        }
        guard model.selectedAreaID == nil else {
            await model.refreshSelected()
            return
        }
        // WAVE-065: 0 → silence · 1 → auto · N → chooser (not unbound forever).
        if let id = AutonomosAreaBindJudgment.autoBindID(areas: model.areas) {
            await model.selectArea(id)
        } else if AutonomosAreaBindJudgment.face(
            areas: model.areas,
            selectedAreaID: model.selectedAreaID
        ).needsChooser {
            showAreaBindChooser = true
        }
    }

    func applyRunControl(
        _ action: AutonomosRunControlAction,
        actor: String,
        reason: String
    ) async {
        switch action {
        case .pause:
            await model.control(.pause, operatorActor: actor, reason: reason)
        case .resume:
            await model.control(.resume, operatorActor: actor, reason: reason)
        case .kill:
            await model.control(.kill, operatorActor: actor, reason: reason)
        case .startExecute:
            await model.startRun(mode: .execute, operatorActor: actor, operatorReason: reason)
        case .startDryRun:
            await model.startRun(mode: .dryRun, operatorActor: actor, operatorReason: reason)
        }
    }
}
// MARK: - AutonomosMapChrome

enum AutonomosMapChrome {
    static func kicker(_ text: String, live: Bool, alert: Bool = false) -> some View {
        HStack(spacing: 8) {
            if live || alert {
                Text(alert ? "※" : "✦")
                    .font(AtlasFont.serif(12))
                    .foregroundStyle(alert ? AtlasTheme.alert : AtlasTheme.accent)
                    .accessibilityHidden(true)
            }
            Text(text.uppercased())
                .font(AtlasFont.mono(10))
                .tracking(1.4)
                .foregroundStyle(alert ? AtlasTheme.alert : (live ? AtlasTheme.accent : AtlasTheme.textTertiary))
        }
    }

    static func heroTitle(_ text: String, size: CGFloat = 30) -> some View {
        Text(text)
            .font(AtlasFont.serif(size, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    static func heroSub(_ text: String) -> some View {
        Text(text)
            .font(AtlasFont.serifItalic(15))
            .foregroundStyle(AtlasTheme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    static var hairline: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        AtlasTheme.separator.opacity(0.12),
                        AtlasTheme.separator.opacity(0.95),
                        AtlasTheme.separator.opacity(0.12)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .padding(.vertical, 4)
    }

    static func section(_ text: String) -> some View {
        Text(text.uppercased())
            .font(AtlasFont.mono(10))
            .tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
    }

    static func primaryCTA(_ title: String, enabled: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AtlasFont.serif(15, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary.opacity(enabled ? 1 : 0.35))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .background(AtlasTheme.textPrimary.opacity(enabled ? 0.055 : 0.03), in: Capsule())
                .overlay(Capsule().strokeBorder(Color.white.opacity(enabled ? 0.08 : 0.04), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    static func quietCTA(_ title: String, danger: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AtlasFont.serif(15))
                .foregroundStyle(danger ? AtlasTheme.alert : AtlasTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .overlay(
                    Capsule().strokeBorder(
                        danger ? AtlasTheme.alert.opacity(0.35) : AtlasTheme.separator.opacity(0.7),
                        lineWidth: 1
                    )
                )
        }
        .buttonStyle(.plain)
    }
}
