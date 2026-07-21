import AtlasCore
import SwiftUI
import Foundation
import UserNotifications
import Observation

// Cycle 044 fuse → AutonomosView.swift

struct AutonomosView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var destination: AutonomosDestination?
    @State var selectedUnitID: String?
    @State var showNewSheet = false

    var model: AutonomosModel { session.autonomos }

    /// Face = catálogo local; masthead quieto.
    private var isHeaderHealthy: Bool { true }

    private var contentPhaseID: String {
        switch model.phase {
        case .idle: "idle"
        case .loading: "loading"
        case .loaded: "loaded"
        case .failed: "failed"
        }
    }

    private var selectedUnit: AutonomosUnit? {
        guard let selectedUnitID else { return nil }
        return model.operatorUnit(id: selectedUnitID)
    }

    private var headerTitle: String {
        guard let destination else { return "Autônomos" }
        if case .hub = destination {
            return selectedUnit?.name ?? "Autônomo"
        }
        return destination.navTitle
    }

    private var headerSubtitle: String {
        guard let destination, let unit = selectedUnit else { return "" }
        switch destination {
        case .hub: return unit.paused ? "Parado" : "Vivo"
        case .evolution: return unit.name
        }
    }

    private var headerSubtitleLive: Bool {
        guard let destination, let unit = selectedUnit else { return false }
        switch destination {
        case .hub, .evolution: return !unit.paused
        }
    }

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                AutonomosViewHeader(
                    auditModeEnabled: session.auditModeEnabled,
                    canRefresh: false,
                    isHealthy: isHeaderHealthy,
                    title: headerTitle,
                    subtitle: headerSubtitle,
                    subtitleLive: headerSubtitleLive,
                    trailing: destination == nil ? .create : .none,
                    reduceMotion: reduceMotion,
                    onBack: {
                        if let destination {
                            self.destination = destination.backTarget
                            if self.destination == nil {
                                selectedUnitID = nil
                            }
                        } else {
                            dismiss()
                        }
                    },
                    onRefresh: {},
                    onCreate: { showNewSheet = true }
                )
                phaseContent
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
                    .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.autonomosScreen)
        .task { await model.load() }
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch model.phase {
        case .idle, .loading:
            VStack {
                Spacer()
                // TraceEvidenceLoading owns spoken wait + updatesFrequently.
                TraceEvidenceLoading(text: "abrindo catálogo Autônomos…", reduceMotion: reduceMotion)
                Spacer()
            }
        case .failed(let message):
            VStack {
                Spacer()
                AutonomosFleetFailureEmpty(message: message) {
                    Task { await model.load() }
                }
                Spacer()
            }
        case .loaded:
            AutonomosMapShell(
                model: model,
                destination: $destination,
                selectedUnitID: $selectedUnitID,
                showNewSheet: $showNewSheet
            )
        }
    }
}

/// Falha de carregamento do catálogo Autônomos.
struct AutonomosFleetFailureEmpty: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .atlasSans(24)
                .foregroundStyle(AtlasTheme.domOperacional.opacity(0.9))
                .accessibilityHidden(true)
            Text("Catálogo fora de alcance.")
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Text(message)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(message)
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry()
            } label: {
                Text("Tentar de novo")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.accent)
                    .frame(minWidth: 160, minHeight: 48)
                    .contentShape(Rectangle())
            }
            .buttonStyle(AutonomosPrimaryButtonStyle())
            .accessibilityIdentifier(A11yID.autonomosRetry)
            .accessibilityLabel("tentar de novo")
            .accessibilityHint("tenta reabrir o catálogo Autônomos")
            .accessibilityAddTraits(.isButton)
            .accessibilitySortPriority(8)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 28)
        .frame(maxWidth: 420)
        // Contain: header + retry stay separately focusable for VoiceOver.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.autonomosLoadFailure)
    }
}

/// Cabeçalho Autônomos — voltar, título, + (lista). Sem refresh mentiroso.
struct AutonomosViewHeader: View {
    enum Trailing {
        case none
        case refresh
        case create
    }

    let auditModeEnabled: Bool
    let canRefresh: Bool
    let isHealthy: Bool
    var title: String = "Autônomos"
    var subtitle: String = ""
    var subtitleLive: Bool = false
    var trailing: Trailing = .refresh
    let reduceMotion: Bool
    let onBack: () -> Void
    let onRefresh: () -> Void
    var onCreate: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            backButton
            titleBlock
            Spacer()
            trailingButton
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, 8)
    }

    @ViewBuilder
    private var trailingButton: some View {
        switch trailing {
        case .none: EmptyView()
        case .create: createButton
        case .refresh: refreshButton
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(AtlasFont.serif(21, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if !subtitle.isEmpty {
                Text(subtitle.uppercased())
                    .font(AtlasFont.mono(10)).tracking(1.2)
                    .foregroundStyle(subtitleLive ? AtlasTheme.accent : AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
            if auditModeEnabled {
                Text("MODO AUDITORIA")
                    .font(AtlasFont.mono(9)).tracking(1.0)
                    .foregroundStyle(AtlasTheme.domOperacional)
                    .accessibilityHidden(true)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(spokenTitle())
        .accessibilityIdentifier(A11yID.autonomosHeader)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: isHealthy)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: auditModeEnabled)
    }

    private var backButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onBack()
        } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold)
                .foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 44, height: 44)
                .atlasGlassCircle()
                .contentShape(Circle())
        }
        .accessibilityLabel("voltar")
        .accessibilityHint("volta um nível no mapa Autônomos")
        .accessibilityIdentifier(A11yID.autonomosBack)
        .accessibilityAddTraits(.isButton)
    }

    private var createButton: some View {
        Button {
            // Medium: primary create entry from catalog chrome.
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onCreate()
        } label: {
            Image(systemName: "plus")
                .atlasSans(17, .semibold)
                .foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 44, height: 44)
                .atlasGlassCircle()
                .contentShape(Circle())
        }
        .accessibilityLabel("Novo Autônomo")
        .accessibilityHint("abre o formulário para criar um Autônomo")
        .accessibilityIdentifier(A11yID.autonomosNew)
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(9) // primary catalog create surfaces early in VO
    }

    private var refreshButton: some View {
        Button {
            if canRefresh { AtlasMotion.softImpact(reduceMotion: reduceMotion) }
            onRefresh()
        } label: {
            Image(systemName: "arrow.clockwise")
                .atlasSans(15, .medium)
                .foregroundStyle(canRefresh ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                .frame(width: 44, height: 44)
                .atlasGlassCircle()
                .contentShape(Circle())
        }
        .disabled(!canRefresh)
        .opacity(canRefresh ? 1 : 0.45)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: canRefresh)
        .accessibilityLabel(
            canRefresh
                ? "atualizar instância selecionada"
                : "atualizar indisponível, selecione uma instância"
        )
        .accessibilityHint(
            canRefresh ? "recarrega estado da área selecionada" : "nenhuma instância selecionada"
        )
        .accessibilityIdentifier(A11yID.autonomosRefresh)
        .accessibilityAddTraits(.isButton)
    }

    private func spokenTitle() -> String {
        var parts = [title, subtitle]
        if auditModeEnabled { parts.append("modo auditoria") }
        return parts.joined(separator: ", ")
    }
}


/// Destinos vivos da face Autônomos v9: lista → hub → evolução.
/// Decisões/incidentes do motor ficam para §5 create — não há rota local mentindo superfície.
enum AutonomosDestination: Hashable, Identifiable {
    case hub
    case evolution

    var id: String {
        switch self {
        case .hub: "hub"
        case .evolution: "evolution"
        }
    }

    var navTitle: String {
        switch self {
        case .hub: "Autônomo"
        case .evolution: "Evolução"
        }
    }

    /// Voltar hierárquico: evolução → hub → lista.
    var backTarget: AutonomosDestination? {
        switch self {
        case .hub: nil
        case .evolution: .hub
        }
    }
}

/// Vestimenta do hub (v9) — quiet/live do catálogo local; sem contagem de backlog.
enum AutonomosHubVestment: Equatable {
    case live
    case quiet
}


/// Shell Autônomos v9 — catálogo do operador → hub → evolução · pílula · Novo.
struct AutonomosMapShell: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let model: AutonomosModel
    @Binding var destination: AutonomosDestination?
    @Binding var selectedUnitID: String?
    @Binding var showNewSheet: Bool
    @State private var showingAsk = false
    @State private var askThreadId: ThreadID?
    @State private var confirmEnd = false
    @State private var selfConstructionReceipt: SelfConstructionReceipt?
    @State private var nightly = NightlyProposalController.shared
    @State private var nightlyStartProposal: NightlyProposalController.ProposalPayload?

    private var selectedUnit: AutonomosUnit? {
        guard let selectedUnitID else { return nil }
        return model.operatorUnit(id: selectedUnitID)
    }

    private var vestmentForAsk: AutonomosHubVestment {
        guard let unit = selectedUnit else { return .quiet }
        return unit.paused ? .quiet : .live
    }

    /// Só ciclos com merge real — nunca fabrica “melhorou”.
    private var latestMergeProvedReceipt: SelfConstructionReceipt? {
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
        // Contain: catalog vs hub/evolution remain separately focusable destinations.
        .accessibilityElement(children: .contain)
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
            SelfConstructionReceiptSheet(receipt: receipt)
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
            Button("Encerrar de vez", role: .destructive) {
                // Medium: governed destructive commit (lista local).
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                deleteSelected()
            }
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
    }

    /// Catálogo do operador + baseline Nightly/Ritmo (aprender-com-o-uso).
    private var catalogFace: some View {
        VStack(spacing: 0) {
            if let receipt = latestMergeProvedReceipt {
                selfConstructionBanner(receipt)
            }
            if let error = model.controlError {
                controlErrorBanner(error)
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

            AutonomosListView(
                units: model.operatorUnits,
                onOpen: { unit in
                    selectedUnitID = unit.id
                    destination = .hub
                },
                onCreate: { showNewSheet = true }
            )
        }
        // Contain: banner, rhythm, list/empty stay separately focusable.
        .accessibilityElement(children: .contain)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.controlError)
    }

    /// Falha honesta do dry-run / load — nunca some o erro em silêncio.
    private func controlErrorBanner(_ error: String) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            model.controlError = nil
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .atlasSans(14, .semibold)
                    .foregroundStyle(AtlasTheme.alert)
                    .accessibilityHidden(true)
                Text(error)
                    .font(AtlasFont.serif(14))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 12)
            .frame(minHeight: 48)
            .contentShape(Rectangle())
            .background(AtlasTheme.alert.opacity(0.08))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(error)
        .accessibilityHint("toque para dispensar")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.autonomosControlError)
    }

    private func selfConstructionBanner(_ receipt: SelfConstructionReceipt) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            selfConstructionReceipt = receipt
        } label: {
            HStack(spacing: 10) {
                Text("✦")
                    .font(AtlasFont.serif(14, .semibold))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("O Atlas melhorou o próprio app")
                        .font(AtlasFont.serif(15, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityHidden(true)
                    Text("Merge comprovado · toque o recibo")
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .accessibilityHidden(true)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 14)
            .frame(minHeight: 56)
            .contentShape(Rectangle())
            .background(AtlasTheme.surface.opacity(0.55))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("O Atlas melhorou o próprio app, recibo com merge comprovado")
        .accessibilityHint("abre o recibo de auto-construção")
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(8) // rare proven receipt — surface early in VO
        .accessibilityIdentifier(A11yID.autonomosSelfConstructionBanner)
    }

    @ViewBuilder
    private func route(_ destination: AutonomosDestination) -> some View {
        switch destination {
        case .hub:
            if let unit = selectedUnit {
                AutonomosHubView(
                    unit: unit,
                    onNavigate: { self.destination = $0 },
                    onPause: { model.setOperatorUnitPaused(id: unit.id, paused: true) },
                    onResume: { model.setOperatorUnitPaused(id: unit.id, paused: false) },
                    onEnd: { confirmEnd = true }
                )
            } else {
                missingUnit
            }
        case .evolution:
            AutonomosEvolutionView(unit: selectedUnit)
        }
    }

    private var missingUnit: some View {
        VStack(alignment: .leading, spacing: 12) {
            AutonomosMapChrome.heroTitle("Autônomo ausente", size: 26)
            Text("Volte à lista e abra de novo.")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .padding(AtlasTheme.Space.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Autônomo ausente. Volte à lista e abra de novo.")
        .accessibilityIdentifier(A11yID.autonomosMissingUnit)
    }

    private func deleteSelected() {
        guard let id = selectedUnitID else { return }
        model.removeOperatorUnit(id: id)
        selectedUnitID = nil
        destination = nil
    }

    private var askPillDock: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg.opacity(0.92), AtlasTheme.bg],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 28)
            .allowsHitTesting(false)
            AgenticPill(
                invite: AutonomosAskContext.invite(destination: destination, vestment: vestmentForAsk),
                accessibilityId: A11yID.autonomosAskPill
            ) {
                showingAsk = true
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.bottom, 10)
        }
        .background(AtlasTheme.bg.opacity(0.01))
    }

    private var askConversationSheet: some View {
        ConversationView(
            client: session.client,
            threadId: askThreadId,
            title: selectedUnit?.name ?? "Autônomos",
            emptyPrompt: AutonomosAskContext.invite(destination: destination, vestment: vestmentForAsk),
            emptySuggestions: AutonomosAskContext.emptySuggestions(destination: destination),
            taskKind: "autonomos",
            workspace: nil,
            draft: "",
            turnFacts: { [selectedUnit, destination] _ in
                AutonomosAskContext.facts(unit: selectedUnit, destination: destination)
            },
            onThread: { askThreadId = $0 },
            hidesNavigationBack: true
        )
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(AtlasTheme.bg)
        .presentationCornerRadius(28)
    }
}


// Linha de ritmo — autossuficiente: lê as janelas aprendidas do AtlasDayRhythm
// e abre a folha "O ritmo do seu dia" ao toque. O aprendizado não some quando
// completa: a linha amadurece e passa a dizer o que foi aprendido.
// Sheet → AutonomosRhythmSheet.swift · Copy → AutonomosRhythmSheet+Copy.swift

struct AutonomosRhythmLearningLine: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Placeholder até o actor devolver as janelas reais — a linha existe
    /// imediatamente (UITest + layout estáveis).
    @State private var windows = AtlasDayRhythm.Windows(dayEnd: nil, dayStart: nil, sampleDays: 0)
    @State private var rhythmSheetShown = false
    @State private var nightly = NightlyProposalController.shared

    var body: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            rhythmSheetShown = true
        } label: {
            HStack(spacing: 5) {
                Text(AutonomosRhythmCopy.line(windows, paused: nightly.isProposalMuted))
                    .font(AtlasFont.mono(10))
                    .lineLimit(2)
                Image(systemName: "chevron.right")
                    .atlasSans(7, .semibold)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AutonomosRhythmCopy.spokenLine(windows, paused: nightly.isProposalMuted))
        .accessibilityHint("mostra o que o Atlas aprendeu do seu dia")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.autonomosRhythmLine)
        .sheet(isPresented: $rhythmSheetShown) {
            AutonomosRhythmSheet(windows: windows)
        }
        .task { windows = await AtlasSession.rhythm.windows(minimumDays: 4) }
    }
}


/// Pack de contexto Autônomos v9 — presentation-only; pack nunca na cara.
enum AutonomosAskContext {
    static func invite(destination: AutonomosDestination?, vestment: AutonomosHubVestment) -> String {
        switch destination {
        case .evolution:
            return "resuma isto"
        case .hub:
            break
        case nil:
            return "o que mudou hoje?"
        }
        switch vestment {
        case .live: return "o que ele fez hoje?"
        case .quiet: return "devo retomar?"
        }
    }

    static func emptySuggestions(destination: AutonomosDestination?) -> [String] {
        switch destination {
        case .evolution:
            return ["o que mudou hoje?", "o que ele melhorou?"]
        case .hub:
            return ["devo retomar?", "o que ele fez?"]
        case nil:
            return ["novo Autônomo", "o que mudou hoje?"]
        }
    }

    static func facts(unit: AutonomosUnit?, destination: AutonomosDestination?) -> String {
        var lines: [String] = [
            "Contexto Autônomos (ocasião). Pack local anexa sempre; intenção do operador pode pedir outro mundo — não bloqueie por silo.",
        ]
        if let unit {
            lines.append("Autônomo: \(unit.name).")
            lines.append("Carta: \(unit.charter)")
            lines.append(unit.paused ? "Estado: pausado." : "Estado: vivo no escopo local.")
            lines.append("Idade: \(unit.ageLabel).")
        } else {
            lines.append("Lista de Autônomos — nenhum aberto.")
        }
        if let destination {
            lines.append("Tela: \(destination.navTitle).")
        }
        lines.append("Create Server de Autônomo ainda pendente (§5); catálogo local pode sumir no kill do app.")
        lines.append("Pause/retomar/encerrar: controles da face; NL de chat ainda não autoriza tools de escrita no wire.")
        lines.append("Transfer/decide do motor não têm face nesta versão — não invente recibos de transferência.")
        return lines.joined(separator: "\n")
    }
}


/// Evolução — timeline deste Autônomo. Sem motor vinculado = ausência honesta.
struct AutonomosEvolutionView: View {
    let unit: AutonomosUnit?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AutonomosMapChrome.kicker("Evolução", live: unit?.paused == false)
                    .padding(.bottom, 14)
                    .accessibilityHidden(true)
                if let unit {
                    Text(unit.ageLabel)
                        .font(AtlasFont.mono(28, .semibold))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .monospacedDigit()
                        .padding(.bottom, 8)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("Evolução de \(unit.name), \(unit.ageLabel)")
                    Text(unit.charter)
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .padding(.bottom, 28)
                        .accessibilityLabel(unit.charter)
                }

                AutonomosMapChrome.section("Marcos")
                    .padding(.bottom, 12)

                Text("Ainda sem prova publicada neste Autônomo.")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("Ainda sem prova publicada neste Autônomo.")

                Text("Quando o Server aceitar create, os ciclos aparecem aqui — só deste escopo.")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.top, 10)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel(
                        "Quando o Server aceitar create, os ciclos aparecem aqui — só deste escopo."
                    )
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .padding(.bottom, 140)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier(A11yID.autonomosEvolution)
        // Contain without fused label: age header and empty proof stay landmarks.
        .accessibilityElement(children: .contain)
    }
}


/// Hub de um Autônomo do operador — presença → fato → verbo → Evolução.
/// Sem backlog de área de sistema. Sem número mentiroso.
struct AutonomosHubView: View {
    let unit: AutonomosUnit
    let onNavigate: (AutonomosDestination) -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onEnd: () -> Void

    private var vestment: LocalVestment {
        unit.paused ? .quiet : .live
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AutonomosMapChrome.kicker(kickerLine, live: !unit.paused)
                    .padding(.bottom, 14)
                    .accessibilityHidden(true)
                AutonomosMapChrome.heroTitle(vestment.hero)
                    .padding(.bottom, 10)
                    .accessibilityLabel("\(unit.name), \(vestment.hero), \(kickerLine)")
                    .accessibilityAddTraits(.isHeader)
                Text(unit.charter)
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 28)
                    .accessibilityLabel(unit.charter)

                primaryVerb
                    .padding(.bottom, 8)

                AutonomosMapChrome.hairline
                    .padding(.top, 12)
                    .padding(.bottom, 10)

                AutonomosMapNavLine(
                    title: "Evolução",
                    meta: "ainda sem provas",
                    action: { onNavigate(.evolution) }
                )

                if unit.paused {
                    AutonomosMapNavLine(title: "Encerrar", meta: "", danger: true, action: onEnd)
                } else {
                    // Medium: Pausar is a governed presence commit (mirrors Retomar).
                    AutonomosMapNavLine(title: "Pausar", meta: "", haptic: .medium, action: onPause)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .padding(.bottom, 140)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier(A11yID.autonomosHub)
        // Contain: hero, charter, Retomar/nav lines stay separately focusable.
        .accessibilityElement(children: .contain)
    }

    private var kickerLine: String {
        "\(vestment.kicker) · \(unit.ageLabel)"
    }

    @ViewBuilder
    private var primaryVerb: some View {
        switch vestment {
        case .quiet:
            AutonomosMapChrome.primaryCTA("Retomar", haptic: .medium, action: onResume)
                .accessibilityHint("retoma este Autônomo a partir da pausa")
        case .live:
            EmptyView()
        }
    }

    private enum LocalVestment {
        case live
        case quiet

        var kicker: String {
            switch self {
            case .live: "Vivo"
            case .quiet: "Parado"
            }
        }

        var hero: String {
            switch self {
            case .live: "No escopo"
            case .quiet: "Em pausa"
            }
        }
    }
}


/// Lista de Autônomos do operador — índice soberano. Vazio até criar. Zero áreas de sistema.
struct AutonomosListView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let units: [AutonomosUnit]
    let onOpen: (AutonomosUnit) -> Void
    let onCreate: () -> Void

    var body: some View {
        Group {
            if units.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .accessibilityIdentifier(A11yID.autonomosList)
    }

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(units) { unit in
                    unitRow(unit)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 12)
            .padding(.bottom, 140)
        }
        .scrollIndicators(.hidden)
        // Contain: each unit row stays a separate VO focus.
        .accessibilityElement(children: .contain)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer(minLength: 36)
            Text("✦")
                .font(AtlasFont.serif(28))
                .foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .accessibilityHidden(true)
            AutonomosMapChrome.heroTitle("Nenhum ainda", size: 32)
            Text("Crie um Autônomo com escopo fechado. Ele evolui só nisso — 24/7.")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(
                    "Crie um Autônomo com escopo fechado. Ele evolui só nisso, 24 por 7."
                )
            // Medium: primary entry into create flow on empty catalog.
            AutonomosMapChrome.primaryCTA("Novo Autônomo", haptic: .medium, action: onCreate)
                .accessibilityHint("abre o formulário para criar um Autônomo")
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        // Contain: hero speaks as header; Novo CTA remains a separate target.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.autonomosListEmpty)
    }

    private func unitRow(_ unit: AutonomosUnit) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onOpen(unit)
        } label: {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(unit.name)
                        .font(AtlasFont.serif(22, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(unit.charter)
                        .font(AtlasFont.serifItalic(14))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(unit.ageLabel)
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                trailing(unit)
            }
            .padding(.vertical, 18)
            .frame(minHeight: 56, alignment: .top)
            .contentShape(Rectangle())
            .opacity(unit.paused ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            AutonomosMapChrome.hairline
        }
        // Ignore children so spoken(unit) is the single VO node (no double name/charter).
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken(unit))
        .accessibilityHint("abre o hub deste Autônomo")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.autonomosUnit(unit.id))
    }

    @ViewBuilder
    private func trailing(_ unit: AutonomosUnit) -> some View {
        if unit.paused {
            Text("pausado")
                .font(AtlasFont.mono(10))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .textCase(.uppercase)
                .padding(.top, 6)
                // Row combine speaks "pausado"; visual UPPERCASE is decoration only.
                .accessibilityHidden(true)
        } else {
            Circle()
                .fill(AtlasTheme.accent.opacity(0.85))
                .frame(width: 5, height: 5)
                .padding(.top, 10)
                .accessibilityHidden(true)
        }
    }

    private func spoken(_ unit: AutonomosUnit) -> String {
        var parts = [unit.name, unit.charter]
        parts.append(unit.paused ? "pausado" : "vivo")
        parts.append(unit.ageLabel)
        return parts.joined(separator: ", ")
    }
}


/// Folha Novo Autônomo — nome + carta (mockup v9).
struct AutonomosNewSheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var name = ""
    @State private var charter = ""
    let onCreate: (String, String) -> Void
    let onCancel: () -> Void

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    AutonomosMapChrome.heroTitle("Novo Autônomo", size: 28)
                    Text("Um escopo fechado. Ele evolui só nisso.")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel("Um escopo fechado. Ele evolui só nisso.")

                    field(
                        label: "Nome",
                        placeholder: "ex.: Agente iOS Dinheiro",
                        text: $name,
                        axis: .horizontal,
                        a11yHint: "nome curto do Autônomo",
                        a11yID: A11yID.autonomosNewName
                    )
                    field(
                        label: "Carta",
                        placeholder: "O que este Autônomo pode e não pode tocar.",
                        text: $charter,
                        axis: .vertical,
                        a11yHint: "escopo fechado em português claro",
                        a11yID: A11yID.autonomosNewCharter
                    )

                    AutonomosMapChrome.primaryCTA("Criar", enabled: canCreate, haptic: .medium) {
                        onCreate(name, charter)
                    }
                    .accessibilityHint(canCreate ? "cria o Autônomo no catálogo" : "digite um nome para criar")
                    AutonomosMapChrome.quietCTA("Cancelar", action: onCancel)
                        .accessibilityHint("fecha sem criar")
                }
                .padding(AtlasTheme.Space.screen)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(AtlasTheme.bg)
            .accessibilityIdentifier(A11yID.autonomosNew)
            // Contain: fields and CTAs stay separately focusable.
            .accessibilityElement(children: .contain)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AtlasTheme.bg)
    }

    private func field(
        label: String,
        placeholder: String,
        text: Binding<String>,
        axis: Axis,
        a11yHint: String,
        a11yID: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AtlasFont.mono(10))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .textCase(.uppercase)
                // Visual only — TextField carries accessibilityLabel(label).
                .accessibilityHidden(true)
            Group {
                if axis == .vertical {
                    TextField(placeholder, text: text, axis: .vertical)
                        .lineLimit(3...6)
                } else {
                    TextField(placeholder, text: text)
                }
            }
            .font(AtlasFont.serif(17))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: axis == .horizontal ? 48 : 88, alignment: .topLeading)
            .background(AtlasTheme.bgRecessed, in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous)
                    .strokeBorder(AtlasTheme.separator.opacity(0.55), lineWidth: 1)
            )
            .accessibilityLabel(label)
            .accessibilityHint(a11yHint)
            .accessibilityIdentifier(a11yID)
        }
    }
}


/// Folha padrão de governança: quem autoriza + motivo auditável.
/// Compacta (era floresta de peels) — um arquivo, contrato de a11y estável.
struct AutonomosReasonSheet: View {
    let title: String
    let explainer: String
    var reasonOptional: Bool = false
    let onConfirm: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var actor = ""
    @State private var reason: String

    init(
        title: String,
        explainer: String,
        reasonOptional: Bool = false,
        initialReason: String = "",
        onConfirm: @escaping (String, String) -> Void
    ) {
        self.title = title
        self.explainer = explainer
        self.reasonOptional = reasonOptional
        self.onConfirm = onConfirm
        _reason = State(initialValue: initialReason)
    }

    private var canSubmit: Bool {
        !actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (reasonOptional || !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Ação governada") {
                    Text(title).accessibilityAddTraits(.isHeader)
                    Text(explainer).font(.footnote).foregroundStyle(.secondary)
                }
                Section("Operador") {
                    TextField("Quem autoriza", text: $actor)
                        .frame(minHeight: 44)
                        .accessibilityIdentifier(A11yID.autonomosReasonActor)
                        .accessibilityHint("nome de quem autoriza a ação governada")
                }
                Section(reasonOptional ? "Motivo (opcional no ensaio)" : "Motivo") {
                    TextField("Motivo auditável", text: $reason, axis: .vertical)
                        .lineLimit(3...6)
                        .frame(minHeight: 88, alignment: .topLeading)
                        .accessibilityIdentifier(A11yID.autonomosReasonField)
                        .accessibilityHint(
                            reasonOptional
                                ? "motivo auditável opcional no ensaio"
                                : "motivo auditável registrado no ledger"
                        )
                }
            }
            .navigationTitle("Confirmar ação")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    AtlasCloseToolbarButton(
                        title: "Cancelar",
                        spokenLabel: "cancelar ação governada",
                        spokenHint: "fecha sem registrar recibo",
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirmar") {
                        // Medium: governed pause/end with operator receipt.
                        AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                        onConfirm(actor, reason)
                        dismiss()
                    }
                    .disabled(!canSubmit)
                    .accessibilityIdentifier(A11yID.autonomosReasonSubmit)
                    .accessibilityLabel(
                        canSubmit
                            ? "confirmar \(title.lowercased())"
                            : "confirmar indisponível, preencha operador e motivo"
                    )
                    .accessibilityHint(
                        canSubmit
                            ? "registra operador e motivo no recibo governado"
                            : "preencha quem autoriza e o motivo"
                    )
                    .accessibilityAddTraits(.isButton)
                    .accessibilitySortPriority(canSubmit ? 9 : 0)
                }
            }
            .accessibilityIdentifier(A11yID.autonomosReasonSheet)
            // Contain without fused sheet label so fields/confirm stay focusable.
            .accessibilityElement(children: .contain)
        }
    }
}


// Cycle 044 fuse → AutonomosRhythmSheet.swift

/// "O ritmo do seu dia" — a explicação do aprender-com-o-uso. Mostra o que o
/// Atlas aprendeu (janelas do dia), o que observou hoje e o que faz com isso
/// (proposta noturna). Só afirma o que está provado no registro local (C13).
struct AutonomosRhythmSheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let windows: AtlasDayRhythm.Windows
    @State private var today: AtlasDayRhythm.DaySummary?
    @State private var nightly = NightlyProposalController.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("APRENDER COM O USO")
                .font(AtlasFont.mono(10, .semibold))
                .foregroundStyle(AtlasTheme.accent)
                .kerning(1.2)
            Text("O ritmo do seu dia")
                .font(AtlasFont.serif(22, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)

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
                    Button {
                        AtlasMotion.softImpact(reduceMotion: reduceMotion)
                        nightly.unmuteProposal()
                    } label: {
                        Text("Reativar propostas noturnas")
                            .font(AtlasFont.mono(11, .semibold))
                            .foregroundStyle(AtlasTheme.accent)
                            .frame(minHeight: 48, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("reativar propostas noturnas")
                    .accessibilityHint("volta a mostrar a proposta das 21h quando o Atlas tiver algo a dizer")
                    .accessibilityIdentifier(A11yID.autonomosRhythmUnmute)
                    .accessibilityAddTraits(.isButton)
                }
            }

            Spacer(minLength: 0)

            Text("aprendido e guardado só neste iPhone — nada sai do aparelho")
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

/// Copy do ritmo — a linha, as falas e os parágrafos da folha. Toda afirmação
/// vem das janelas reais; aprendizado incompleto é dito como incompleto.
enum AutonomosRhythmCopy {
    static func line(_ windows: AtlasDayRhythm.Windows, paused: Bool = false) -> String {
        let base: String
        if windows.sampleDays < 4 {
            base = "aprendendo seu ritmo · dia \(max(1, windows.sampleDays)) de 4"
        } else if let dayEnd = hour(windows.dayEnd) {
            base = "ritmo aprendido · seu dia termina ~\(dayEnd)"
        } else {
            base = "ritmo aprendido · \(windows.sampleDays) dias de uso"
        }
        return paused ? "\(base) · propostas em pausa" : base
    }

    static func spokenLine(_ windows: AtlasDayRhythm.Windows, paused: Bool = false) -> String {
        let base: String
        if windows.sampleDays < 4 {
            base = "aprendendo seu ritmo, dia \(max(1, windows.sampleDays)) de 4"
        } else if let dayEnd = hour(windows.dayEnd) {
            base = "ritmo aprendido: seu dia costuma terminar perto das \(dayEnd)"
        } else {
            base = "ritmo aprendido em \(windows.sampleDays) dias de uso"
        }
        return paused ? "\(base). Propostas noturnas em pausa" : base
    }

    static func learnedParagraph(_ windows: AtlasDayRhythm.Windows) -> String {
        if windows.sampleDays < 4 {
            return "O Atlas observa quando seu dia de trabalho começa e termina. Faltam \(4 - windows.sampleDays) \(4 - windows.sampleDays == 1 ? "dia" : "dias") para ele conhecer seu ritmo."
        }
        return "O Atlas aprendeu seu ritmo observando o uso real — a mediana dos seus últimos dias de trabalho."
    }

    static func whatHappensParagraph(_ windows: AtlasDayRhythm.Windows) -> String {
        if windows.sampleDays < 4 {
            return "Quando o ritmo estiver aprendido, no fim do seu dia o Atlas vai propor uma missão noturna — a frota continua enquanto você descansa."
        }
        return "No fim do seu dia, se houve trabalho, o Atlas propõe uma missão noturna — a frota continua enquanto você descansa, e de manhã o resultado espera por você."
    }

    static func todayLine(_ today: AtlasDayRhythm.DaySummary?) -> String {
        guard let today, !today.workspaces.isEmpty else {
            return "nenhum trabalho registrado ainda"
        }
        return today.workspaces.joined(separator: " · ")
    }

    /// Placar só existe depois da primeira resposta — zero histórico, zero linha.
    static func scoreLine(_ score: (accepted: Int, dismissed: Int)) -> String? {
        guard score.accepted + score.dismissed > 0 else { return nil }
        let aceitas = "\(score.accepted) \(score.accepted == 1 ? "aceita" : "aceitas")"
        let recusadas = "\(score.dismissed) \(score.dismissed == 1 ? "recusada" : "recusadas")"
        return "\(aceitas) · \(recusadas)"
    }

    /// Janela adaptativa só é dita quando existe — 0 min = sem linha.
    static func adjustmentLine(_ minutes: Int) -> String? {
        guard minutes > 0 else { return nil }
        return "+\(minutes) min — seu horário real de resposta"
    }

    static func hour(_ components: DateComponents?) -> String? {
        guard let hour = components?.hour else { return nil }
        return String(format: "%02d:%02d", hour, components?.minute ?? 0)
    }
}



/// Chrome tipográfico do mapa Autônomos v5 — sem cards, sem chips, sem ouro de chrome.
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
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        // Spoken title stays natural case — uppercase tracking is visual only.
        .accessibilityLabel(text)
    }

    static func heroTitle(_ text: String, size: CGFloat = 30) -> some View {
        Text(text)
            .font(AtlasFont.serif(size, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
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
            .accessibilityHidden(true)
    }

    static func section(_ text: String) -> some View {
        Text(text.uppercased())
            .font(AtlasFont.mono(10))
            .tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityAddTraits(.isHeader)
            // Spoken title stays natural case — uppercase tracking is visual only.
            .accessibilityLabel(text)
    }

    enum CTAHaptic {
        case soft
        case medium
    }

    @MainActor
    static func primaryCTA(
        _ title: String,
        enabled: Bool = true,
        haptic: CTAHaptic = .soft,
        action: @escaping () -> Void
    ) -> some View {
        AutonomosMapPrimaryCTA(title: title, enabled: enabled, haptic: haptic, action: action)
    }

    @MainActor
    static func quietCTA(_ title: String, danger: Bool = false, action: @escaping () -> Void) -> some View {
        AutonomosMapQuietCTA(title: title, danger: danger, action: action)
    }
}

/// Primary map CTA — Environment Reduce Motion (not UIAccessibility global).
private struct AutonomosMapPrimaryCTA: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    var enabled: Bool = true
    var haptic: AutonomosMapChrome.CTAHaptic = .soft
    let action: () -> Void

    var body: some View {
        Button {
            if enabled {
                switch haptic {
                case .soft: AtlasMotion.softImpact(reduceMotion: reduceMotion)
                case .medium: AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                }
            }
            action()
        } label: {
            Text(title)
                .atlasSans(14, .medium)
                .foregroundStyle(AtlasTheme.textPrimary.opacity(enabled ? 1 : 0.35))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .background(AtlasTheme.textPrimary.opacity(enabled ? 0.055 : 0.03), in: Capsule())
                .overlay(Capsule().strokeBorder(Color.white.opacity(enabled ? 0.1 : 0.04), lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(enabled ? "confirma \(title.lowercased())" : "indisponível"))
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(enabled ? 9 : 0) // primary map CTA surfaces early in VO
    }
}

private struct AutonomosMapQuietCTA: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    var danger: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            // Soft invitation; medium when danger (governed destructive quiet CTA).
            if danger {
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            } else {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
            }
            action()
        } label: {
            Text(title)
                .atlasSans(14)
                .foregroundStyle(danger ? AtlasTheme.alert : AtlasTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .overlay(
                    Capsule().strokeBorder(
                        danger ? AtlasTheme.alert.opacity(0.35) : AtlasTheme.separator.opacity(0.7),
                        lineWidth: 1
                    )
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(danger ? "ação destrutiva" : "ação secundária, \(title.lowercased())"))
        .accessibilityAddTraits(.isButton)
    }
}

// Cycle 046 fused AutonomosChrome+Buttons.swift

struct AutonomosPrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.bg)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .frame(minHeight: 48) // HIG 44+; match primary map CTA breath
            .background(
                Capsule().fill(
                    AtlasTheme.accent.opacity(
                        configuration.isPressed && !reduceMotion ? 0.72 : 1
                    )
                )
            )
            .contentShape(Capsule())
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
            .animation(
                reduceMotion
                    ? nil
                    : (configuration.isPressed
                        ? .easeOut(duration: AtlasMotion.instinct)
                        : .spring(response: 0.25, dampingFraction: 0.82)),
                value: configuration.isPressed
            )
    }
}


/// Linha › do mapa Autônomos — tipografia, sem cápsula.
struct AutonomosMapNavLine: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    let meta: String
    var danger: Bool = false
    /// Soft default (nav); medium for governed state commits (e.g. Pausar).
    var haptic: AutonomosMapChrome.CTAHaptic = .soft
    let action: () -> Void

    var body: some View {
        Button {
            switch haptic {
            case .soft: AtlasMotion.softImpact(reduceMotion: reduceMotion)
            case .medium: AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            }
            action()
        } label: {
            HStack(spacing: 10) {
                Text(title)
                    .atlasSans(15.5, .medium)
                    .foregroundStyle(danger ? AtlasTheme.alert : AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !meta.isEmpty {
                    Text(meta)
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1)
                }
                Text("›")
                    .atlasSans(13)
                    .foregroundStyle(danger ? AtlasTheme.alert.opacity(0.7) : AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 14)
            .frame(minHeight: 48, alignment: .center)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) { AutonomosMapChrome.hairline.padding(.vertical, 0) }
        .accessibilityLabel(meta.isEmpty ? title : "\(title), \(meta)")
        .accessibilityHint(danger ? "abre confirmação de \(title.lowercased())" : "abre \(title.lowercased())")
        .accessibilityAddTraits(.isButton)
        // Medium governed (Pausar) and danger (Encerrar) surface early in VO.
        .accessibilitySortPriority(haptic == .medium || danger ? 8 : 0)
        .accessibilityIdentifier(A11yID.autonomosNav(title))
    }
}


// Cycle 044 fuse → SelfConstructionReceipt.swift

struct SelfConstructionReceipt: Identifiable {
    let cycle: AtlasAutonomosCycle
    let finding: AtlasAutonomosFinding?

    var id: String { cycle.id }

    /// Merge só quando o servidor publica `merge_performed` e hash não vazio.
    var hasMergeProof: Bool {
        cycle.mergePerformed && cycle.mergeHash.nonEmpty != nil
    }
}

extension SelfConstructionReceipt {
    var title: String {
        if let findingTitle = finding?.title.nonEmpty { return findingTitle }
        if hasMergeProof { return "Entrega comprovada no ledger" }
        return "Ciclo registrado sem merge neste recorte"
    }

    var ruleLabel: String {
        if let ruleId = finding?.ruleId?.nonEmpty, let text = finding?.ruleText?.nonEmpty {
            return "\(ruleId) — \(text)"
        }
        if let ruleId = finding?.ruleId?.nonEmpty { return "\(ruleId) — regra publicada sem texto neste recorte." }
        return "Regra não publicada no recorte deste recibo."
    }
}

extension SelfConstructionReceipt {
    var proofLine: String {
        let integrity = cycle.loopReceiptIntegrity.nonEmpty ?? "integridade não publicada"
        var parts = ["integridade \(integrity)", "ciclo \(cycle.cycleIndex)"]
        if hasMergeProof, let hash = cycle.mergeHash.nonEmpty {
            parts.insert("merge \(String(hash.prefix(8)))", at: 1)
        } else {
            parts.append("merge não publicado")
        }
        return parts.joined(separator: " · ")
    }
}

extension SelfConstructionReceiptSheet {
    func spokenRuleLabel() -> String {
        "regra citada, \(receipt.ruleLabel)"
    }

    func spokenProofLabel() -> String {
        "prova, \(receipt.proofLine)"
    }
}

extension SelfConstructionReceiptSheet {
    func spokenHumanSilenceLabel() -> String {
        "você não foi necessário, entrega sem portão"
    }

    func spokenRevertQueueLabel() -> String {
        "veto na fila, ainda não desfeito"
    }
}

extension SelfConstructionReceiptSheet {
    var receiptSealHeader: some View {
        HStack(spacing: 7) {
            Image(systemName: "checkmark.seal")
                .atlasSans(11, .bold)
                .accessibilityHidden(true)
            Text("RECIBO DE AUTO-CONSTRUÇÃO")
                .font(AtlasFont.mono(11))
                .tracking(1.0)
                .accessibilityHidden(true)
        }
        .foregroundStyle(AtlasTheme.textTertiary)
    }
}

extension SelfConstructionReceiptSheet {
    var canSubmitRevert: Bool {
        !actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension SelfConstructionReceiptSheet {
    func proofChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenProofLabel())
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofCopyBlock: some View {
        Text(receipt.proofLine)
            .font(AtlasFont.mono(12))
            .foregroundStyle(AtlasTheme.textPrimary)
            .textSelection(.enabled)
            .accessibilityHidden(true)
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var revertQueueBanner: some View {
        if revertReceipt != nil {
            Text("na fila · ainda não desfeito")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.domOperacional)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.domOperacional.opacity(0.08)))
                .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.domOperacional.opacity(0.35), lineWidth: 1))
                .transition(reduceMotion ? .identity : .opacity)
                .accessibilityLabel(spokenRevertQueueLabel())
        }
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var ruleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Regra citada")
                .font(AtlasFont.mono(10))
                .tracking(0.9)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text("“\(receipt.ruleLabel)”")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenRuleLabel())
    }
}

extension SelfConstructionReceiptSheet {
    var receiptShell: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            receiptBody
        }
        .accessibilityIdentifier(A11yID.selfReceiptSheet)
        // Contain without fused sheet label so proof lines and veto stay focusable.
        .accessibilityElement(children: .contain)
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var humanSilenceLine: some View {
        if receipt.hasMergeProof {
            Text("você não foi necessário — entrega sem portão")
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel(spokenHumanSilenceLabel())
        }
    }
}

extension SelfConstructionReceiptSheet {
    var receiptBody: some View {
        VStack(alignment: .leading, spacing: 14) {
            receiptSealHeader
            receiptTitleBlock
            ruleBlock
            proofBlock
            revertQueueBanner
            vetoSection
            humanSilenceLine
            Spacer(minLength: 0)
        }
        .padding(22)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: revertReceipt != nil)
    }
}

extension SelfConstructionReceiptSheet {
    var receiptTitleBlock: some View {
        Text(receipt.title)
            .font(AtlasFont.serif(18, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var vetoSection: some View {
        if canRevert {
            // Contain without fused label: fields + Desfazer stay focusable.
            vetoFields
                .accessibilityElement(children: .contain)
        }
    }
}

extension SelfConstructionReceiptSheet {
    func spokenActorHint() -> String {
        "nome de quem autoriza o veto retroativo"
    }

    func spokenReasonHint() -> String {
        "motivo auditável registrado no ledger"
    }
}

extension SelfConstructionReceiptSheet {
    func spokenVetoSubmitLabel(canSubmit: Bool) -> String {
        canSubmit ? "desfazer com recibo" : "desfazer indisponível, preencha autor e motivo"
    }

    func spokenVetoSubmitHint(canSubmit: Bool) -> String {
        canSubmit
            ? "envia veto retroativo auditável para este ciclo"
            : "informe quem autoriza e o motivo auditável"
    }
}

extension SelfConstructionReceiptSheet {
    var vetoSubmitButton: some View {
        Button {
            // Medium: veto with receipt is governed commit.
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onRevert(actor, reason)
        } label: {
            vetoSubmitLabel
        }
        .buttonStyle(PressableScale())
        .disabled(!canSubmitRevert)
        .accessibilityIdentifier(A11yID.selfReceiptVeto)
        .accessibilityLabel(spokenVetoSubmitLabel(canSubmit: canSubmitRevert))
        .accessibilityHint(spokenVetoSubmitHint(canSubmit: canSubmitRevert))
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(canSubmitRevert ? 9 : 0)
    }
}

extension SelfConstructionReceiptSheet {
    var vetoFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("veto retroativo · com recibo")
                .font(AtlasFont.mono(10))
                .tracking(0.9)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
            vetoTextFields
            vetoSubmitButton
        }
    }
}

extension SelfConstructionReceiptSheet {
    var vetoSubmitLabel: some View {
        HStack(spacing: 7) {
            Image(systemName: "arrow.uturn.backward")
                .accessibilityHidden(true)
            Text("Desfazer — com recibo")
        }
        .atlasSans(14, .medium)
        .frame(maxWidth: .infinity, minHeight: 48)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .foregroundStyle(AtlasTheme.domOperacional)
        .atlasCard(cornerRadius: 13)
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofBlockStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            proofBlockTitle
            proofCopyBlock
        }
    }
}

extension SelfConstructionReceiptSheet {
    var proofBlockTitle: some View {
        Text("Prova")
            .font(AtlasFont.mono(10))
            .tracking(0.9)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofBlock: some View {
        proofChrome(proofBlockStack)
    }
}

extension SelfConstructionReceiptSheet {
    var vetoActorField: some View {
        TextField("Quem autoriza", text: $actor)
            .font(.system(.callout))
            .textInputAutocapitalization(.never)
            .padding(10)
            .frame(minHeight: 44, alignment: .center)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface.opacity(0.55)))
            .accessibilityLabel("quem autoriza o veto")
            .accessibilityHint(spokenActorHint())
    }
}

extension SelfConstructionReceiptSheet {
    var vetoReasonField: some View {
        TextField("Motivo auditável", text: $reason, axis: .vertical)
            .font(.system(.callout))
            .lineLimit(2...4)
            .padding(10)
            .frame(minHeight: 88, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface.opacity(0.55)))
            .accessibilityLabel("motivo auditável do veto")
            .accessibilityHint(spokenReasonHint())
    }
}

extension SelfConstructionReceiptSheet {
    var vetoTextFields: some View {
        Group {
            vetoActorField
            vetoReasonField
        }
    }
}

struct SelfConstructionReceiptSheet: View {
    let receipt: SelfConstructionReceipt
    var canRevert: Bool = false
    var revertReceipt: AtlasAutonomosCycleRevertResponse? = nil
    var onRevert: (String, String) -> Void = { _, _ in }

    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var actor = ""
    @State var reason = ""

    var body: some View {
        receiptShell
    }
}


// Cycle 044 fuse → NightlyProposal.swift

@MainActor
@Observable
final class NightlyProposalController: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NightlyProposalController()

    let nightlyIdentifier = "atlas.nightly"
    let morningIdentifier = "atlas.morning"
    @ObservationIgnored let center = UNUserNotificationCenter.current()
    @ObservationIgnored var openAutonomos: (() -> Void)?
    @ObservationIgnored var immediateNightlyDateKey: String?

    var pendingProposal: ProposalPayload?  // set interno: família de peels
    private(set) var mutedUntil: Date?

    /// Casca: silêncio total enquanto mute ativo — sem card, sem placeholder, sem toast.
    var isProposalMuted: Bool { isMuted() }

    private override init() {
        super.init()
        mutedUntil = AtlasSession.nightlyProposalMutedUntil()
    }

    func installAsNotificationDelegate() {
        center.delegate = self
    }

    func registerOpenAutonomos(_ handler: @escaping () -> Void) { openAutonomos = handler }

    /// aprendizado na folha do ritmo (nunca silêncio inexplicado).
    static let dismissStreakPauseThreshold = 3

    func dismissProposal() {
        pendingProposal = nil
        let streak = AtlasSession.recordNightlyProposalDismissal()
        if streak >= Self.dismissStreakPauseThreshold {
            muteProposal(days: 7)
            AtlasSession.setNightlyProposalAutoPaused(true)
        }
    }

    func muteProposal(days: Int, now: Date = .init()) {
        let days = max(1, days)
        let until = AtlasSession.muteNightlyProposal(days: days, now: now)
        mutedUntil = until
        pendingProposal = nil
        AtlasSession.setNightlyProposalAutoPaused(false)
        center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier])
    }

    /// Desfaz o silêncio na hora: limpa o mute (manual ou automático), zera o
    /// streak de recusas e rearma o agendamento (vive na folha do ritmo).
    func unmuteProposal() {
        AtlasSession.clearNightlyProposalMute()
        AtlasSession.setNightlyProposalAutoPaused(false)
        AtlasSession.resetNightlyProposalStreak()
        mutedUntil = nil
        Task { await scheduleForBackground() }
    }

    func accept(_ proposal: ProposalPayload) async {
        let delayMinutes = Int(Date().timeIntervalSince(proposal.proposedAt) / 60)
        AtlasSession.recordNightlyProposalAccept(delayMinutes: delayMinutes)
        await scheduleMorning(after: proposal)
        pendingProposal = nil
    }

    #if DEBUG
    func installDemoIfRequested(arguments: [String] = ProcessInfo.processInfo.arguments) {
        guard arguments.contains("-atlas.nightly.demo") else { return }
        // UITest não herda mute de runs anteriores no simulador.
        unmuteProposal()
        pendingProposal = ProposalPayload(workspaces: ["atlas-native"])
    }
    #endif

    func isMuted(now: Date = .init()) -> Bool {
        guard let mutedUntil else { return false }
        if mutedUntil > now { return true }
        self.mutedUntil = AtlasSession.clearExpiredNightlyProposalMute(now: now)
        return false
    }
}

/// Proposta noturna — guard mute+proposta, transição editorial com Reduce Motion.
struct AutonomosNightlyProposalBlock: View {
    let nightly: NightlyProposalController
    let onAccept: (NightlyProposalController.ProposalPayload) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    private var visibilityToken: String {
        guard let proposal = nightly.pendingProposal, !nightly.isProposalMuted else { return "hidden" }
        return proposal.id
    }

    var body: some View {
        Group {
            if let proposal = nightly.pendingProposal, !nightly.isProposalMuted {
                NightlyProposalCard(
                    proposal: proposal,
                    onAccept: { onAccept(proposal) },
                    onDismiss: { nightly.dismissProposal() },
                    onMute: { nightly.muteProposal(days: $0) }
                )
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            } else if let spoken = nightly.spokenMuteStatus() {
                Color.clear
                    .frame(height: 0)
                    .accessibilityLabel(spoken)
                    .accessibilityAddTraits(.isStaticText)
            }
        }
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: visibilityToken)
    }
}

/// Card da proposta noturna — masthead + copy + Preparar/hoje não/silenciar.
struct NightlyProposalCard: View {
    let proposal: NightlyProposalController.ProposalPayload
    let onAccept: () -> Void
    /// Silêncio: some o card sem toast, sem confirmação, sem fila.
    let onDismiss: () -> Void
    let onMute: (Int) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    /// Hora aprendida do fim do dia — masthead diz o ritmo real, não "21h" fixo.
    @State private var learnedDayEnd: String?

    static let muteDays = [1, 3, 7]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            masthead
            copyBlock
            actionRow
        }
        .padding(14)
        .atlasCard(cornerRadius: AtlasTheme.Radius.card)
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.nightlyProposalCard)
        .task {
            let windows = await AtlasSession.rhythm.windows(minimumDays: 4)
            learnedDayEnd = AutonomosRhythmCopy.hour(windows.dayEnd)
        }
    }

    private var masthead: some View {
        HStack(spacing: 8) {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                .accessibilityHidden(true)
            Text(learnedDayEnd.map { "MISSÃO NOTURNA · NO SEU RITMO (~\($0))" }
                ?? "MISSÃO NOTURNA · NO SEU RITMO")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
        }
    }

    private var copyBlock: some View {
        Group {
            Text("Hoje você trabalhou em \(proposal.workspaceText).")
                .font(AtlasFont.serif(16, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text("A frota pode continuar enquanto você descansa.")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var actionRow: some View {
        HStack(spacing: 10) {
            Button("Preparar missão noturna") {
                // Medium: primary accept of the nightly mission.
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                onAccept()
            }
            .buttonStyle(AutonomosPrimaryButtonStyle())
            .accessibilityIdentifier(A11yID.nightlyProposalAccept)
            .accessibilityLabel(Self.spokenAcceptLabel())
            .accessibilityHint(Self.spokenAcceptHint())
            .accessibilityAddTraits(.isButton)
            .accessibilitySortPriority(9) // primary mission accept surfaces early in VO

            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onDismiss()
            } label: {
                Text("hoje não")
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.horizontal, 10)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableScale())
            .accessibilityIdentifier(A11yID.nightlyProposalDismiss)
            .accessibilityLabel(Self.spokenDismissLabel())
            .accessibilityHint(Self.spokenDismissHint())
            .accessibilityAddTraits(.isButton)

            Menu {
                ForEach(Self.muteDays, id: \.self) { days in
                    Button("\(days) dia\(days == 1 ? "" : "s")") {
                        AtlasMotion.softImpact(reduceMotion: reduceMotion)
                        onMute(days)
                    }
                    .accessibilityLabel(Self.spokenMuteOption(days: days))
                    .accessibilityHint(Self.spokenMuteOptionHint())
                }
            } label: {
                Text("silenciar")
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityIdentifier(A11yID.nightlyProposalMute)
            .accessibilityLabel(Self.spokenMuteMenuLabel())
            .accessibilityHint(Self.spokenMuteMenuHint())
            .accessibilityAddTraits(.isButton)
        }
    }

    // MARK: - Spoken

    static func spokenAcceptLabel() -> String { "preparar missão noturna" }
    static func spokenAcceptHint() -> String {
        "abre o ensaio governado da missão noturna"
    }
    static func spokenDismissLabel() -> String { "hoje não" }
    static func spokenDismissHint() -> String {
        "descarta a proposta em silêncio, sem confirmação"
    }
    static func spokenMuteMenuLabel() -> String { "silenciar propostas noturnas" }
    static func spokenMuteMenuHint() -> String {
        "oculta card e notificações por 1, 3 ou 7 dias, em silêncio"
    }
    static func spokenMuteOption(days: Int) -> String {
        "silenciar por \(days) \(days == 1 ? "dia" : "dias")"
    }
    static func spokenMuteOptionHint() -> String {
        "remove a proposta e pausa notificações, sem toast"
    }
}

extension NightlyProposalController {
    func spokenMuteStatus(now: Date = .init()) -> String? {
        guard isMuted(now: now), let until = mutedUntil else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.unitsStyle = .full
        let prazo = formatter.localizedString(for: until, relativeTo: now)
        if AtlasSession.nightlyProposalAutoPaused() {
            return "propostas em pausa — você recusou as últimas \(Self.dismissStreakPauseThreshold); voltam \(prazo)"
        }
        return "propostas noturnas silenciadas até \(prazo)"
    }
}

extension NightlyProposalController {
    func nightlyBackgroundContent(workspaces: [String]) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = NotificationCopy.nightlyTitle
        content.body = NotificationCopy.nightlyBody(workspaces: workspaces)
        content.sound = .default
        content.userInfo = [
            "atlas.route": "autonomos-nightly",
            "atlas.workspaces": workspaces,
        ]
        return content
    }
}

extension NightlyProposalController {
    enum NotificationCopy {
        static let nightlyTitle = "A frota pode trabalhar esta noite"

        static func nightlyBody(workspaces: [String]) -> String {
            "Hoje você mexeu em \(workspaces.joined(separator: ", ")). "
                + "Quer pôr os Autônomos nisso enquanto descansa?"
        }

        /// Manhã: convite sem afirmar entrega — fatos só no digest em Autônomos.
        static let morningTitle = "Resumo da missão noturna"
        static let morningBody = "Abra Autônomos para ver o que a frota entregou com prova."
    }
}

extension NightlyProposalController {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        let route = userInfo["atlas.route"] as? String
        let workspaces = userInfo["atlas.workspaces"] as? [String]
        await MainActor.run {
            NightlyProposalController.shared.handle(route: route, workspaces: workspaces)
        }
    }
}

extension NightlyProposalController {
    func handle(route: String?, workspaces: [String]?) {
        guard let route else { return }
        if route == "autonomos-nightly" {
            guard !isMuted() else {
                openAutonomos?()
                return
            }
            guard let workspaces, !workspaces.isEmpty else {
                openAutonomos?()
                return
            }
            pendingProposal = ProposalPayload(workspaces: workspaces)
            openAutonomos?()
        } else if route == "autonomos" {
            openAutonomos?()
        }
    }
}

extension NightlyProposalController {
    struct ProposalPayload: Identifiable, Equatable {
        let id: String
        let workspaces: [String]
        let proposedAt: Date

        init(workspaces: [String], proposedAt: Date = .init()) {
            self.workspaces = workspaces
            self.proposedAt = proposedAt
            self.id = workspaces.joined(separator: "|") + "-\(Int(proposedAt.timeIntervalSince1970))"
        }

        var workspaceText: String { workspaces.joined(separator: ", ") }

        var prefilledReason: String {
            "missão noturna proposta às \(Self.hourMinute(proposedAt)) — foco: \(workspaceText)"
        }

        private static func hourMinute(_ date: Date) -> String {
            let components = Calendar.current.dateComponents([.hour, .minute], from: date)
            return String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0)
        }
    }
}

extension NightlyProposalController {
    func nextDayDate(matching components: DateComponents, after date: Date) -> Date? {
        Calendar.current.date(byAdding: .day, value: 1, to: date).flatMap { Self.date(matching: components, on: $0) }
    }

    static func date(matching time: DateComponents, on date: Date) -> Date? {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = time.hour
        components.minute = time.minute
        return Calendar.current.date(from: components)
    }

    static func calendarTrigger(for date: Date) -> UNCalendarNotificationTrigger {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }

    static func dateKey(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }
}

extension NightlyProposalController {
    func nightlyTrigger(dayEnd: DateComponents, now: Date) -> UNNotificationTrigger {
        guard var target = Self.date(matching: dayEnd, on: now) else {
            return Self.calendarTrigger(for: now.addingTimeInterval(60))
        }
        // Janela adaptativa: desliza a proposta para o horário em que o
        // operador realmente responde (mediana dos aceites; dita na folha).
        target += TimeInterval(AtlasSession.nightlyProposalAdjustmentMinutes() * 60)
        if target <= now {
            let today = Self.dateKey(now)
            if immediateNightlyDateKey != today {
                immediateNightlyDateKey = today
                return Self.calendarTrigger(for: now.addingTimeInterval(60))
            }
            return Self.calendarTrigger(for: Calendar.current.date(byAdding: .day, value: 1, to: target) ?? target)
        }
        return Self.calendarTrigger(for: target)
    }
}

extension NightlyProposalController {
    func scheduleForBackground(now: Date = .init()) async {
        guard !isMuted(now: now) else {
            center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier])
            return
        }
        let windows = await AtlasSession.rhythm.windows(minimumDays: 4, now: now)
        guard let dayEnd = windows.dayEnd else {
            center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier, morningIdentifier])
            return
        }

        let summary = await AtlasSession.rhythm.todaySummary(now: now)
        guard !summary.workspaces.isEmpty else {
            center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier])
            return
        }
        guard await canScheduleNotifications() else { return }

        center.removePendingNotificationRequests(withIdentifiers: [nightlyIdentifier])
        let request = UNNotificationRequest(
            identifier: nightlyIdentifier,
            content: nightlyBackgroundContent(workspaces: summary.workspaces),
            trigger: nightlyTrigger(dayEnd: dayEnd, now: now)
        )
        try? await center.add(request)
    }
}

extension NightlyProposalController {
    func scheduleMorning(after proposal: ProposalPayload) async {
        let windows = await AtlasSession.rhythm.windows(minimumDays: 4)
        guard let dayStart = windows.dayStart,
              let date = nextDayDate(matching: dayStart, after: proposal.proposedAt),
              await canScheduleNotifications() else { return }

        let content = UNMutableNotificationContent()
        content.title = NotificationCopy.morningTitle
        content.body = NotificationCopy.morningBody
        content.sound = .default
        content.userInfo = ["atlas.route": "autonomos"]

        center.removePendingNotificationRequests(withIdentifiers: [morningIdentifier])
        try? await center.add(UNNotificationRequest(
            identifier: morningIdentifier,
            content: content,
            trigger: Self.calendarTrigger(for: date)
        ))
    }

    func canScheduleNotifications() async -> Bool {
        let status = await center.notificationSettings().authorizationStatus
        switch status {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }
}


/// Autônomo do operador (escopo fechado). Persistência Server = OBRA §5.
/// Em memória no AutonomosModel até existir create no Core (casca não faz storage).
struct AutonomosUnit: Identifiable, Equatable, Hashable {
    let id: String
    var name: String
    var charter: String
    var createdAt: Date
    var paused: Bool

    var ageLabel: String {
        let seconds = max(0, Int(Date().timeIntervalSince(createdAt)))
        if seconds < 60 { return "agora" }
        if seconds < 3600 { return "\(seconds / 60)m" }
        if seconds < 86_400 { return "\(seconds / 3600)h" }
        let days = seconds / 86_400
        return days == 1 ? "1 dia" : "\(days) dias"
    }
}

/// Motor da área Autônomos. Não conhece Views nem conversa: só projeta o
/// estado real do Atlas Continuous Stewardship Loop para a casca própria 24/7.
/// Load → AutonomosModel+Load.swift · comandos → +Control.swift.
/// Face v9: catálogo local + delivered (recibo merge) + taskHealth (snapshot).
@MainActor
@Observable
final class AutonomosModel {

    let client: AtlasClient

    var phase: LoadPhase = .loaded
    var areas: [AtlasAutonomosArea] = []
    var selectedAreaID: String?
    /// Ciclos entregues da área efetiva — banner de merge comprovado.
    var delivered: AtlasAutonomosDeliveredResponse?
    /// Saúde global da fila do músculo externo (widgets / snapshot).
    var taskHealth: AtlasAutonomosTaskHealthResponse?
    var lastStartRunReceipt: AtlasAutonomosStartRunResponse?
    var controlError: String?
    /// Catálogo do operador (face Autônomos). Em memória até POST create (§5).
    var operatorUnits: [AutonomosUnit] = []

    init(client: AtlasClient) {
        self.client = client
    }

    var selectedArea: AtlasAutonomosArea? {
        areas.first { $0.id == selectedAreaID }
    }

    /// Área efetiva para dry-run: seleção explícita, ou a única registrada.
    /// Zero registrada / ambígua → nil (startRun fala o erro, sem no-op silencioso).
    var runTargetArea: AtlasAutonomosArea? {
        if let selected = selectedArea { return selected }
        let registered = areas.filter(\.registered)
        return registered.count == 1 ? registered.first : nil
    }

    /// Face Autônomos = catálogo local (instantâneo). Áreas do loop hidratam
    /// em segundo plano; surfaces globais (taskHealth) alimentam Continuity.
    func load() async {
        clearSelectionProjection()
        phase = .loaded
        controlError = nil
        do {
            let response = try await client.listAutonomosAreas()
            areas = response.areas
        } catch {
            // Catálogo local funciona sem isto; não derruba a superfície.
        }
        // Uma área registrada: ancora e carrega delivered para o banner.
        if let sole = runTargetArea {
            selectedAreaID = sole.id
        }
        await refreshSelected()
    }

    func clearSelectionProjection() {
        selectedAreaID = nil
        delivered = nil
        taskHealth = nil
    }

    func refreshSelected() async {
        controlError = nil
        do {
            try await loadSelectedDetails()
            if case .idle = phase { phase = .loaded }
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}

extension AutonomosModel {
    func operatorUnit(id: String) -> AutonomosUnit? {
        operatorUnits.first { $0.id == id }
    }

    @discardableResult
    func createOperatorUnit(name: String, charter: String) -> AutonomosUnit {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCharter = charter.trimmingCharacters(in: .whitespacesAndNewlines)
        let unit = AutonomosUnit(
            id: UUID().uuidString,
            name: trimmedName.isEmpty ? "Sem nome" : trimmedName,
            charter: trimmedCharter.isEmpty ? "Escopo ainda sem carta." : trimmedCharter,
            createdAt: Date(),
            paused: true
        )
        operatorUnits.insert(unit, at: 0)
        return unit
    }

    func setOperatorUnitPaused(id: String, paused: Bool) {
        guard let index = operatorUnits.firstIndex(where: { $0.id == id }) else { return }
        operatorUnits[index].paused = paused
    }

    func removeOperatorUnit(id: String) {
        operatorUnits.removeAll { $0.id == id }
    }
}

/// Start dry-run — peel de AutonomosModel.
/// Pause/kill/transfer/decide removidos da face v9 (zero call sites).
extension AutonomosModel {
    /// Um recibo `enqueued` não muda a UI para executando. A confirmação vem
    /// exclusivamente do lease relido em `/live` após o comando.
    /// Sem área efetiva (seleção ou única registrada), falha honesta — nunca no-op.
    func startRun(
        mode: AtlasAutonomosStartRunMode,
        operatorActor: String,
        operatorReason: String
    ) async {
        guard let area = runTargetArea else {
            let registered = areas.filter(\.registered).count
            if registered == 0 {
                controlError = "Nenhuma área registrada no servidor para enfileirar a missão."
            } else {
                controlError = "Há várias áreas registradas — o app ainda não escolhe qual usar neste ensaio."
            }
            return
        }
        controlError = nil
        do {
            let input = AtlasAutonomosStartRunInput(
                mode: mode,
                operatorActor: operatorActor,
                operatorReason: operatorReason,
                focus: area.focus
            )
            lastStartRunReceipt = try await client.startAutonomosRun(area: area.id, input: input)
            // Ancora a seleção no alvo real do dry-run para o próximo refresh.
            selectedAreaID = area.id
            try await loadSelectedDetails()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}

extension AutonomosModel {
    /// Surfaces vivas na face v9: delivered (banner merge) + taskHealth (snapshot).
    /// live/cycles/backlog/fleet/digest removidos — zero leitores na casca.
    func loadSelectedDetails() async throws {
        async let taskHealthRequest = client.autonomosTaskHealth()
        if let area = selectedArea ?? runTargetArea {
            async let deliveredRequest = client.autonomosDelivered(area: area.id, focus: area.focus)
            delivered = try? await deliveredRequest
            if selectedAreaID == nil {
                selectedAreaID = area.id
            }
        } else {
            delivered = nil
        }
        taskHealth = try? await taskHealthRequest
        AtlasNativeSnapshotWriter.shared.recordAutonomos(self)
    }

    static func publicMessage(_ error: Error) -> String {
        if let client = error as? AtlasAutonomosClientError {
            switch client {
            case .missingOperatorActor:
                return "Informe quem autoriza esta ação."
            case .missingOperatorReasonForExecute:
                return "Informe o motivo auditável antes de iniciar uma execução."
            case .missingFindingHash:
                return "Escolha uma evidência ou finding antes de registrar a decisão."
            case .missingRationaleForHighRiskAccept:
                return "Aceites de risco alto exigem uma justificativa auditável."
            case .missingTransferReason:
                return "Informe o motivo auditável antes de transferir a missão."
            case .missingRevertReason:
                return "Informe o motivo auditável antes de reverter um ciclo."
            }
        }
        if let api = error as? AtlasApiError { return api.message }
        // Triagem honesta: contrato divergente não pode se esconder atrás de
        // "fora de alcance" (lição do decode do backlog, 2026-07-17).
        if error is DecodingError {
            return "O servidor respondeu num formato que o app não reconhece — contrato divergente; atualize o app."
        }
        if let url = error as? URLError {
            switch url.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "Sem conexão — verifique o Wi-Fi ou a VPN do Atlas."
            case .timedOut:
                return "O servidor demorou demais para responder — tente de novo."
            case .cannotConnectToHost, .cannotFindHost:
                return "Não foi possível alcançar o Mac — o atlas-server está de pé?"
            default: break
            }
        }
        return "Não foi possível atualizar o estado do Autônomos agora."
    }
}
