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
            Button(AutonomosReasonJudgment.productEndUnit, role: .destructive) { deleteSelected() }
            Button(AutonomosReasonJudgment.productCancel, role: .cancel) {}
        } message: {
            Text(AutonomosListJudgment.productEndUnitMessage)
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
                title: AutonomosTransferJudgment.productReasonTitle,
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
                    transferReceiptLine: AutonomosTransferJudgment.productReceiptLine(model.lastTransferReceipt)
                        ?? model.controlError,
                    incidentMeta: AutonomosTaskHealthJudgment.productHubIncidentMeta(health: model.taskHealth),
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
            Text(AutonomosListJudgment.productReturnToList)
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
                invite: AutonomosAskContext.productInvite(destination: destination, vestment: vestmentForAsk),
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
            emptyPrompt: AutonomosAskContext.productInvite(destination: destination, vestment: vestmentForAsk),
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
                    Text(AutonomosListJudgment.productSelfImproved)
                        .font(AtlasFont.serif(15, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text(AutonomosListJudgment.productMergeProved)
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
        AutonomosRunControlJudgment.productReceiptLine(
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

// MARK: - AutonomosRhythmSheet

// MARK: - Judgment

// MARK: - Types

/// Exclusive Autônomos day-rhythm face (WAVE-077).
enum AutonomosRhythmFace: Equatable {
    case learning(day: Int)
    case learned
    case paused

    var productWord: String {
        switch self {
        case .learning: return "learning"
        case .learned: return "learned"
        case .paused: return "paused"
        }
    }

    var spokenFace: String {
        switch self {
        case .learning(let day):
            return "aprendendo seu ritmo, dia \(day) de 4"
        case .learned:
            return "ritmo aprendido"
        case .paused:
            return "propostas noturnas em pausa"
        }
    }
}

// MARK: - Judgment

/// Pure day-rhythm grammar — face · line · spoken · paragraphs · pack.
enum AutonomosRhythmJudgment {

    static let learningThresholdDays = 4

    static func face(
        sampleDays: Int,
        paused: Bool
    ) -> AutonomosRhythmFace {
        if paused { return .paused }
        if sampleDays < learningThresholdDays {
            return .learning(day: max(1, sampleDays))
        }
        return .learned
    }

    static func face(
        windows: AtlasDayRhythm.Windows,
        paused: Bool
    ) -> AutonomosRhythmFace {
        face(sampleDays: windows.sampleDays, paused: paused)
    }

    static func hour(_ components: DateComponents?) -> String? {
        guard let hour = components?.hour else { return nil }
        return String(format: "%02d:%02d", hour, components?.minute ?? 0)
    }

    static func line(
        windows: AtlasDayRhythm.Windows,
        paused: Bool = false
    ) -> String {
        let base: String
        if windows.sampleDays < learningThresholdDays {
            base = "aprendendo seu ritmo · dia \(max(1, windows.sampleDays)) de \(learningThresholdDays)"
        } else if let dayEnd = hour(windows.dayEnd) {
            base = "ritmo aprendido · seu dia termina ~\(dayEnd)"
        } else {
            base = "ritmo aprendido · \(windows.sampleDays) dias de uso"
        }
        return paused ? "\(base) · propostas em pausa" : base
    }

    static func spokenLine(
        windows: AtlasDayRhythm.Windows,
        paused: Bool = false
    ) -> String {
        let base: String
        if windows.sampleDays < learningThresholdDays {
            base = "aprendendo seu ritmo, dia \(max(1, windows.sampleDays)) de \(learningThresholdDays)"
        } else if let dayEnd = hour(windows.dayEnd) {
            base = "ritmo aprendido: seu dia costuma terminar perto das \(dayEnd)"
        } else {
            base = "ritmo aprendido em \(windows.sampleDays) dias de uso"
        }
        return paused ? "\(base). Propostas noturnas em pausa" : base
    }

    static func learnedParagraph(_ windows: AtlasDayRhythm.Windows) -> String {
        if windows.sampleDays < learningThresholdDays {
            let left = learningThresholdDays - windows.sampleDays
            return "O Atlas observa quando seu dia de trabalho começa e termina. Faltam \(left) \(left == 1 ? "dia" : "dias") para ele conhecer seu ritmo."
        }
        return "O Atlas aprendeu seu ritmo observando o uso real — a mediana dos seus últimos dias de trabalho."
    }

    static func whatHappensParagraph(_ windows: AtlasDayRhythm.Windows) -> String {
        if windows.sampleDays < learningThresholdDays {
            return "Quando o ritmo estiver aprendido, no fim do seu dia o Atlas vai propor uma missão noturna — a frota continua enquanto você descansa."
        }
        return "No fim do seu dia, se houve trabalho, o Atlas propõe uma missão noturna — a frota continua enquanto você descansa, e de manhã o resultado espera por você."
    }

    static func packFacts(
        windows: AtlasDayRhythm.Windows,
        paused: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(windows: windows, paused: paused)
        facts.append("rhythm_face: \(face.productWord)")
        facts.append("rhythm_sample_days: \(windows.sampleDays)")
        if let dayEnd = hour(windows.dayEnd) {
            facts.append("rhythm_day_end: \(dayEnd)")
        } else {
            absences.append("hora de fim do dia ainda não aprendida")
        }
        if let dayStart = hour(windows.dayStart) {
            facts.append("rhythm_day_start: \(dayStart)")
        }
        switch face {
        case .learning:
            absences.append("ritmo ainda em amostragem (< \(learningThresholdDays) dias)")
        case .learned:
            break
        case .paused:
            absences.append("propostas noturnas em pausa sobre o ritmo")
        }
        return (facts, absences)
    }
}

// MARK: - Sheet

struct AutonomosRhythmSheet: View {
    let windows: AtlasDayRhythm.Windows
    @State private var today: AtlasDayRhythm.DaySummary?
    @State private var nightly = NightlyProposalController.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(AutonomosListJudgment.productLearnFromUseKicker)
                .font(AtlasFont.mono(10, .semibold))
                .foregroundStyle(AtlasTheme.accent)
                .kerning(1.2)
            Text(AutonomosListJudgment.productRhythmTitle)
                .font(AtlasFont.serif(22, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)

            Text(AutonomosRhythmCopy.learnedParagraph(windows))
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                if let dayStart = AutonomosRhythmCopy.hour(windows.dayStart) {
                    rhythmRow("dia começa", "~\(dayStart)")
                }
                if let dayEnd = AutonomosRhythmCopy.hour(windows.dayEnd) {
                    rhythmRow("dia termina", "~\(dayEnd)")
                }
                rhythmRow("amostra", "\(windows.sampleDays) \(windows.sampleDays == 1 ? "dia" : "dias") de uso")
                rhythmRow("hoje", AutonomosRhythmCopy.todayLine(today))
                if let score = AutonomosRhythmCopy.scoreLine(AtlasSession.nightlyProposalScore()) {
                    rhythmRow("propostas", score)
                }
                if let adjustment = AutonomosRhythmCopy.adjustmentLine(AtlasSession.nightlyProposalAdjustmentMinutes()) {
                    rhythmRow("ajuste", adjustment)
                }
            }

            Text(AutonomosRhythmCopy.whatHappensParagraph(windows))
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if let muted = nightly.spokenMuteStatus() {
                VStack(alignment: .leading, spacing: 8) {
                    Text(muted)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                    Button(NightlyProposalJudgment.productUnmute) {
                        nightly.unmuteProposal()
                    }
                    .font(AtlasFont.mono(11, .semibold))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityIdentifier(A11yID.autonomosRhythmUnmute)
                }
            }

            Spacer(minLength: 0)

            Text(AutonomosListJudgment.productRhythmFootnote)
                .font(AtlasFont.mono(9.5))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(AtlasTheme.bg)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.autonomosRhythmSheet)
        .accessibilityValue(
            AutonomosRhythmJudgment.face(
                windows: windows,
                paused: nightly.isProposalMuted
            ).productWord
        )
        .task { today = await AtlasSession.rhythm.todaySummary() }
    }

    private func rhythmRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(width: 84, alignment: .leading)
            Text(value)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textPrimary)
        }
        .accessibilityElement(children: .combine)
    }
}

/// WAVE-077: presentation peels → AutonomosRhythmJudgment for face grammar.
enum AutonomosRhythmCopy {
    static func line(_ windows: AtlasDayRhythm.Windows, paused: Bool = false) -> String {
        AutonomosRhythmJudgment.line(windows: windows, paused: paused)
    }

    static func spokenLine(_ windows: AtlasDayRhythm.Windows, paused: Bool = false) -> String {
        AutonomosRhythmJudgment.spokenLine(windows: windows, paused: paused)
    }

    static func learnedParagraph(_ windows: AtlasDayRhythm.Windows) -> String {
        AutonomosRhythmJudgment.learnedParagraph(windows)
    }

    static func whatHappensParagraph(_ windows: AtlasDayRhythm.Windows) -> String {
        AutonomosRhythmJudgment.whatHappensParagraph(windows)
    }

    static func todayLine(_ today: AtlasDayRhythm.DaySummary?) -> String {
        guard let today, !today.workspaces.isEmpty else {
            return "nenhum trabalho registrado ainda"
        }
        return today.workspaces.joined(separator: " · ")
    }

    static func scoreLine(_ score: (accepted: Int, dismissed: Int)) -> String? {
        guard score.accepted + score.dismissed > 0 else { return nil }
        let aceitas = "\(score.accepted) \(score.accepted == 1 ? "aceita" : "aceitas")"
        let recusadas = "\(score.dismissed) \(score.dismissed == 1 ? "recusada" : "recusadas")"
        return "\(aceitas) · \(recusadas)"
    }

    static func adjustmentLine(_ minutes: Int) -> String? {
        guard minutes > 0 else { return nil }
        return "+\(minutes) min — seu horário real de resposta"
    }

    static func hour(_ components: DateComponents?) -> String? {
        AutonomosRhythmJudgment.hour(components)
    }
}
