import SwiftUI
import AtlasCore
import Foundation
import Charts
import UIKit
import Observation

struct ArenaPremiumShell: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(AtlasSession.self) private var session
    @Bindable var model: ArenaModel
    @Binding var selectedTab: ArenaPremiumTab
    @Binding var destination: ArenaPremiumDestination?
    @Binding var selectedSuite: AtlasArenaSuite?
    @Binding var selectedCapability: AtlasArenaCapability?
    @Binding var showingRunSheet: Bool
    @Binding var stoppingRun: AtlasArenaLiveRun?
    @State private var showingAsk = false
    @State private var askThreadId: ThreadID?
    @State private var askDraft = ""
    /// Sheet local da suíte — evita race do binding com o contentor AtlasArenaView.
    @State private var suiteSheet: AtlasArenaSuite?

    var body: some View {
        VStack(spacing: 0) {
            ArenaPremiumTabBar(selection: $selectedTab)
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 6)
                .padding(.bottom, 8)
                .background(AtlasTheme.bg)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 26) {
                    selectedContent
                        .id(selectedTab)
                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 8)))
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 12)
                .padding(.bottom, 108)
                .animation(reduceMotion ? nil : AtlasMotion.editorial, value: selectedTab)
            }
            .scrollIndicators(.hidden)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
        // Contain: tab bar, tab content and ask pill stay separately focusable.
        .accessibilityElement(children: .contain)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if destination == nil {
                askPillDock
            }
        }
        .toolbar { addToolbarItem }
        .navigationDestination(item: $destination) { target in
            ArenaPremiumDestinationView(
                target: target,
                model: model,
                onStop: { stoppingRun = $0 },
                onSuite: { openSuite($0) }
            )
        }
        .sheet(item: $selectedCapability) { capability in
            ArenaPremiumCapabilityDetail(
                capability: capability,
                scoreboard: model.scoreboard,
                engineId: model.arenaSelectedEngineID
            )
        }
        .sheet(item: $stoppingRun) { run in
            ArenaPremiumStopSheet(model: model, run: run)
        }
        .fullScreenCover(item: $suiteSheet) { suite in
            ArenaSuiteSheet(suite: suite)
        }
        .sheet(isPresented: $showingAsk) {
            askConversationSheet
        }
    }

    private func openSuite(_ suite: AtlasArenaSuite) {
        selectedSuite = suite
        suiteSheet = suite
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
                invite: ArenaPremiumAskContext.invite(tab: selectedTab, destination: destination),
                accessibilityId: A11yID.arenaPremiumAskPill
            ) {
                askDraft = ""
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
            title: "Arena",
            emptyPrompt: ArenaPremiumAskContext.invite(tab: selectedTab, destination: destination),
            emptySuggestions: ArenaPremiumAskContext.emptySuggestions(tab: selectedTab),
            taskKind: "arena",
            workspace: nil,
            draft: askDraft,
            turnFacts: { [model, selectedTab] _ in
                ArenaPremiumAskContext.facts(model: model, tab: selectedTab)
            },
            onThread: { askThreadId = $0 },
            hidesNavigationBack: true
        )
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(AtlasTheme.bg)
        .presentationCornerRadius(28)
    }

    @ViewBuilder
    private var selectedContent: some View {
        if model.composite == nil, case .failed = model.phase {
            ArenaPremiumLoadFailureView(model: model)
        } else {
            switch selectedTab {
            case .now:
                ArenaPremiumNowView(
                    model: model,
                    onRun: { showingRunSheet = true },
                    onNavigate: { destination = $0 },
                    onStop: { stoppingRun = $0 }
                )
            case .fleet:
                ArenaPremiumFleetView(model: model)
            case .results:
                ArenaPremiumResultsView(
                    model: model,
                    reduceMotion: reduceMotion,
                    onSuite: { openSuite($0) }
                )
            case .capabilities:
                ArenaPremiumCapabilitiesView(
                    model: model,
                    onCapability: { selectedCapability = $0 }
                )
            }
        }
    }

    @ToolbarContentBuilder
    private var addToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                showingRunSheet = true
            } label: {
                Image(systemName: ArenaPremiumIconography.add)
                    .atlasSans(17, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 48, height: 48)
                    .atlasElevation(radius: 6, y: 2, opacity: 0.14)
                    .contentShape(Circle())
            }
            .accessibilityLabel("Nova medição")
            .accessibilityHint("Escolhe motores, suítes e braços")
            .accessibilityIdentifier(A11yID.arenaPremiumAdd)
            .accessibilityAddTraits(.isButton)
            .accessibilitySortPriority(9) // primary Arena create surfaces early in VO
        }
    }
}


struct ArenaPremiumLoadFailureView: View {
    @Bindable var model: ArenaModel

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ArenaPremiumEmptyGlyph(
                symbol: model.isDomainUnavailable ? "shippingbox" : "wifi.exclamationmark",
                tone: .neutral
            )
            ArenaPremiumKicker(text: model.isDomainUnavailable ? "Arena não publicada" : "Arena indisponível")
            Text(model.isDomainUnavailable ? "A medição ainda não existe neste servidor" : "Não foi possível carregar a medição")
                .font(AtlasFont.serif(31))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(
                model.isDomainUnavailable
                    ? "Nenhum índice, progresso ou resultado foi presumido."
                    : "A tela não transformou a falha de rede em estado vazio."
            )
            .font(AtlasFont.serif(15))
            .foregroundStyle(AtlasTheme.textSecondary)
            ArenaPremiumAction(title: "Tentar novamente", symbol: "arrow.clockwise") {
                Task { await model.load() }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 22)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.arenaPremiumState("failed-load"))
    }
}


/// Hero do motor medido: o nome é o seletor (nunca “Trocar motor”).
/// Só lista opções já medidas — catálogo sem perfil não entra.
struct ArenaPremiumEngineTitle: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let engineID: String
    let options: [String]
    let onSelect: (String) -> Void

    var body: some View {
        if options.count > 1 {
            Menu {
                ForEach(options, id: \.self) { engine in
                    Button {
                        // Soft: engine swap is navigation, not commit.
                        AtlasMotion.softImpact(reduceMotion: reduceMotion)
                        onSelect(engine)
                    } label: {
                        if engine == engineID {
                            Label(ArenaDisplay.engine(engine), systemImage: "checkmark")
                        } else {
                            Text(ArenaDisplay.engine(engine))
                        }
                    }
                }
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(ArenaDisplay.engine(engineID))
                        .font(AtlasFont.serif(33))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Image(systemName: "chevron.down")
                        .atlasSans(13, .semibold)
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                .contentShape(Rectangle())
            }
            .accessibilityLabel("Motor medido, \(ArenaDisplay.engine(engineID))")
            .accessibilityHint("Abre a lista dos outros motores medidos")
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier(A11yID.arenaPremiumEnginePicker)
        } else {
            Text(ArenaDisplay.engine(engineID))
                .font(AtlasFont.serif(33))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
        }
    }
}


struct ArenaPremiumTabBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var selection: ArenaPremiumTab
    @Namespace private var selectionNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ArenaPremiumTab.allCases) { tab in
                Button {
                    guard selection != tab else { return }
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    withAnimation(reduceMotion ? nil : AtlasMotion.editorial) { selection = tab }
                } label: {
                    // Controle fala sans (canon §C); seleção = pílula neutra
                    // ELEVADA (padrão do segmented nativo), não véu de ouro —
                    // ouro é ESTADO, não seleção de controle.
                    Text(tab.rawValue)
                        .font(selection == tab ? AtlasFont.serif(14, .semibold) : AtlasFont.serif(14))
                        .foregroundStyle(selection == tab ? AtlasTheme.textPrimary : AtlasTheme.textTertiary)
                        .frame(maxWidth: .infinity, minHeight: 48) // HIG 44+; match primary CTA breath
                        .background {
                            if selection == tab {
                                Capsule()
                                    .fill(AtlasTheme.surfaceHi)
                                    .atlasElevation(radius: 5, y: 1)
                                    .matchedGeometryEffect(id: "arena-tab", in: selectionNamespace)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tabAccessibilityLabel(tab))
                .accessibilityAddTraits(selection == tab ? [.isButton, .isSelected] : .isButton)
                .accessibilityIdentifier(A11yID.arenaPremiumTab(tab.a11yKey))
                .atlasAccessibilityHint(selection == tab ? "Selecionado" : "Troca aba da Arena")
            }
        }
        .padding(3)
        .background(Capsule().fill(AtlasTheme.bgRecessed.opacity(0.92)))
        .overlay(Capsule().stroke(AtlasTheme.separator.opacity(0.7), lineWidth: 1))
    }

    private func tabAccessibilityLabel(_ tab: ArenaPremiumTab) -> String {
        switch tab {
        case .now: "Agora"
        case .fleet: "Frota"
        case .capabilities: "Capacidades"
        case .results: "Motor"
        }
    }
}


// Cycle 044 fuse → AtlasArenaView.swift

/// Arena — medição de motores (premium only). Dual-stack classic removido (GOD F5).
struct AtlasArenaView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(AtlasSession.self) var session
    @Bindable var model: ArenaModel
    @State var selectedSuite: AtlasArenaSuite?
    @State var showingRunSheet = false
    @State var selectedTab: ArenaPremiumTab = .now
    @State var premiumDestination: ArenaPremiumDestination?
    @State var selectedCapability: AtlasArenaCapability?
    @State var stoppingRun: AtlasArenaLiveRun?

    var body: some View {
        arenaSheets(on:
            arenaLifecycleChrome(
                ArenaPremiumShell(
                    model: model,
                    selectedTab: $selectedTab,
                    destination: $premiumDestination,
                    selectedSuite: $selectedSuite,
                    selectedCapability: $selectedCapability,
                    showingRunSheet: $showingRunSheet,
                    stoppingRun: $stoppingRun
                )
            )
        )
        // NÃO colocar accessibilityIdentifier/label no container da Arena —
        // no iOS 26 isso substitui o id de cada tab/CTA (todos viram
        // "arena-screen") e quebra a bateria XCUITest.
    }
}

extension AtlasArenaView {
    func arenaLifecycleA11y<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("Arena")
            .navigationBarTitleDisplayMode(.inline)
            // O título de navegação já anuncia a superfície. Label/ID no
            // container inteiro substituía o nome e o ID de cada tab e CTA.
    }
}

extension AtlasArenaView {
    func arenaLifecycleTasks<Content: View>(_ content: Content) -> some View {
        content
            .task {
                if case .idle = model.phase {
                    await model.load()
                }
            }
            .onAppear { model.setVisible(true) }
            .onDisappear { model.setVisible(false) }
            .refreshable { await model.load() }
    }
}

extension AtlasArenaView {
    func arenaLifecycleChrome<Content: View>(_ content: Content) -> some View {
        arenaLifecycleTasks(arenaLifecycleA11y(content))
    }
}

// Sheets live da Arena premium (Run + Suite). Engine sheet classic removido.

extension AtlasArenaView {
    func arenaSheets<Content: View>(on content: Content) -> some View {
        content
            // Suite sheet vive no ArenaPremiumShell (estado local) — evita
            // sheet(item:) órfão no contentor que não reapresentava no iOS 26.
            .sheet(isPresented: $showingRunSheet) {
                ArenaRunSheet(model: model)
            }
    }
}


/// Pack de contexto Arena — presentation-only até o contrato Core (§5).
/// Nunca vaza na cara da pílula; só viaja como `turnFacts` humanos.
/// Pack = tela/destino atual; intenção cross-world **não** é bloqueada no texto.
enum ArenaPremiumAskContext {
    static func invite(tab: ArenaPremiumTab, destination: ArenaPremiumDestination?) -> String {
        if let destination {
            switch destination {
            case .execution: return "Pergunte sobre esta execução"
            case .queue: return "Pergunte sobre a fila"
            case .alerts: return "Pergunte sobre estes alertas"
            case .plan: return "Pergunte sobre este plano"
            case .results: return "Pergunte sobre este motor"
            }
        }
        switch tab {
        case .now: return "Pergunte sobre esta medição"
        case .fleet: return "Pergunte sobre a frota medida"
        case .capabilities: return "Pergunte sobre estas capacidades"
        case .results: return "Pergunte sobre este motor"
        }
    }

    /// Suggestions calibradas ao can-do atual (NL chat = leitura; run/stop = CTA).
    static func emptySuggestions(
        tab: ArenaPremiumTab,
        destination: ArenaPremiumDestination? = nil
    ) -> [String] {
        if let destination {
            switch destination {
            case .execution:
                return [
                    "Como está o progresso da execução?",
                    "Onde o Atlas está ganhando nestas corridas?",
                    "Qual corrida precisa de atenção?"
                ]
            case .queue:
                return [
                    "O que está na fila?",
                    "Qual suíte vem a seguir?",
                    "Há bloqueio na fila?"
                ]
            case .alerts:
                return [
                    "Quais alertas importam agora?",
                    "Onde o Atlas regressou?",
                    "Qual suíte abriu exceção?"
                ]
            case .plan:
                return [
                    "Resuma o plano de medição",
                    "O que falta no plano?",
                    "Há plano ativo real?"
                ]
            case .results:
                return [
                    "Explica o índice deste motor",
                    "Quais suítes puxaram o ganho?",
                    "Onde a cobertura é parcial?"
                ]
            }
        }
        switch tab {
        case .now:
            return [
                "Como está o progresso agora?",
                "Onde o Atlas está ganhando nesta medição?",
                "Qual o status ao vivo?"
            ]
        case .fleet:
            return [
                "Qual motor sobe mais com Atlas?",
                "Onde o Atlas regressa na frota?",
                "Compara os motores medidos"
            ]
        case .capabilities:
            return [
                "Quais capacidades regrediram?",
                "Onde o Atlas sobe neste perfil?",
                "Resumo das capacidades cobertas"
            ]
        case .results:
            return [
                "Explica o índice deste motor",
                "Quais suítes puxaram o ganho?",
                "Onde a cobertura é parcial?"
            ]
        }
    }

    /// Fatos em prosa humana — tab **e** destination (nunca forçar Agora em destinos).
    @MainActor
    static func facts(
        model: ArenaModel,
        tab: ArenaPremiumTab,
        destination: ArenaPremiumDestination? = nil
    ) -> String {
        var lines: [String] = [
            "Contexto Arena (medição). Use este pack da ocasião; intenção do operador pode pedir outro mundo — o pack local anexa sempre.",
        ]
        if let destination {
            lines.append("Tela: \(destinationLabel(destination)).")
        } else {
            lines.append("Aba: \(tab.rawValue).")
        }
        if let engine = model.arenaPrimaryEngine {
            lines.append("Motor em foco: \(ArenaDisplay.engine(engine.engine)).")
            lines.append("Índice composto: \(ArenaFormat.score(engine.composite)) / 10.")
            lines.append("Sem Atlas: \(ArenaFormat.score(engine.withoutAtlasComposite)); com Atlas: \(ArenaFormat.score(engine.withAtlasComposite)).")
            if let mult = engine.atlasMultiplier {
                lines.append("Multiplicador Atlas: \(ArenaFormat.multiplier(mult)).")
            }
            if engine.isPartialCoverage {
                lines.append("Cobertura parcial.")
            }
        } else {
            lines.append("Nenhum motor composto publicado ainda.")
        }
        lines.append("Cobertura: \(model.arenaCoverageText).")
        if let phase = model.livePresentation?.phase {
            lines.append("Fase ao vivo: \(phaseLabel(phase)).")
        }
        if let progress = model.livePresentation?.progress {
            lines.append("Progresso: \(progress.completed) de \(progress.total) casos (\(progress.remaining) restantes).")
        }
        if let run = model.arenaPrimaryRun {
            lines.append("Corrida: \(ArenaDisplay.suite(run.suite)) · \(run.arm?.labelPT ?? "braço") · \(run.status.displayPT).")
        }
        let alerts = model.arenaAlertSuiteCount
        lines.append(alerts == 0 ? "Alertas: nenhuma exceção." : "Alertas: \(alerts) exceção(ões).")
        if let narrative = model.report?.narrative, !narrative.isEmpty {
            lines.append("Narrativa publicada: \(narrative)")
        }
        let focusTab = destination == nil ? tab : tabForDestination(destination!)
        if focusTab == .fleet || destination == nil && tab == .fleet, let composite = model.composite {
            lines.append("Frota (\(composite.engines.count) motores), ordenada por ganho Atlas:")
            for engine in composite.engines.prefix(8) {
                let mult = engine.atlasMultiplier.map(ArenaFormat.multiplier) ?? "Não medido"
                lines.append("- \(ArenaDisplay.engine(engine.engine)): \(mult) (sem \(ArenaFormat.score(engine.withoutAtlasComposite)) → com \(ArenaFormat.score(engine.withAtlasComposite)))")
            }
        }
        if focusTab == .capabilities || destination == nil && tab == .capabilities {
            let caps = model.selectedCapabilities?.capabilities ?? []
            let covered = caps.filter { $0.score != nil || $0.withAtlas != nil }.count
            lines.append("Capacidades no perfil: \(covered) cobertas de \(caps.count).")
            for cap in caps.prefix(8) {
                let d: Double? = {
                    guard let a = cap.withAtlas, let b = cap.score else { return nil }
                    return a - b
                }()
                lines.append("- \(cap.labelPt): sem \(ArenaFormat.score(cap.score)) → com \(ArenaFormat.score(cap.withAtlas)) (\(ArenaFormat.signed(d)))")
            }
        }
        if destination == .execution || destination == .queue {
            let live = model.liveRuns?.runs ?? []
            lines.append("Corridas publicadas em live: \(live.count).")
            for run in live.prefix(6) {
                lines.append("- \(ArenaDisplay.suite(run.suite)) · \(run.arm?.labelPT ?? "braço") · \(run.status.displayPT)")
            }
            if live.isEmpty {
                lines.append("Ausência: nenhuma corrida live publicada.")
            }
        }
        if destination == .plan {
            if model.activePlan != nil {
                lines.append("Há plano ativo real no model.")
            } else {
                lines.append("Ausência: sem plano multi-suíte publicado (não invente progresso de plano).")
            }
        }
        lines.append("Ausências: não invente scores; diga “não medido” quando faltar braço ou suíte.")
        lines.append("Ações run/stop: use os controles da Arena (NL de chat ainda não autoriza tools de escrita no wire).")
        return lines.joined(separator: "\n")
    }

    private static func destinationLabel(_ d: ArenaPremiumDestination) -> String {
        switch d {
        case .execution: "Execução"
        case .plan: "Plano"
        case .queue: "Fila"
        case .alerts: "Alertas"
        case .results: "Motor"
        }
    }

    private static func tabForDestination(_ d: ArenaPremiumDestination) -> ArenaPremiumTab {
        switch d {
        case .execution, .queue, .plan, .alerts: .now
        case .results: .results
        }
    }

    private static func phaseLabel(_ phase: AtlasArenaLivePhase) -> String {
        switch phase {
        case .idle: "parada"
        case .queued: "na fila"
        case .running: "ao vivo"
        case .stopping: "parando"
        case .stopped: "parada pelo operador"
        case .completed: "concluída"
        case .failed: "interrompida"
        }
    }
}


struct ArenaPremiumStopSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var model: ArenaModel
    let run: AtlasArenaLiveRun
    @State private var actor = ""
    @State private var reason = ""

    private var valid: Bool {
        !actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isConfirmed: Bool {
        model.lastStopReceipt?.measurementIdPublic == run.measurementIdPublic
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ArenaPremiumEmptyGlyph(symbol: "stop.circle", tone: .negative)
                    ArenaPremiumKicker(text: "Ação governada", tone: .negative)
                        .accessibilityIdentifier(A11yID.arenaPremiumStopSheet)
                    Text("Parar a medição?")
                        .font(AtlasFont.serif(34))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Text("O caso atual termina antes da parada. Casos concluídos e resultados parciais são preservados.")
                        .font(AtlasFont.serif(16))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    fields
                    receipt
                    confirm
                }
                .padding(AtlasTheme.Space.screen)
            }
            .scrollIndicators(.hidden)
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Parar")
            .navigationBarTitleDisplayMode(.inline)
            // Contain: fields and confirm stay separately focusable.
            .accessibilityElement(children: .contain)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AtlasCloseToolbarButton(
                        spokenLabel: "fechar confirmação",
                        spokenHint: "mantém a medição em execução",
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
            }
        }
        .onAppear { model.controlError = nil }
        .onChange(of: model.lastStopReceipt?.receiptHash) { _, hash in
            guard hash != nil, model.lastStopReceipt?.accepted == true else { return }
            AtlasMotion.successNotification(reduceMotion: reduceMotion)
        }
    }

    private var fields: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Chrome da casa: .roundedBorder rendia caixas BRANCAS no dark
            // (a mesma quebra já corrigida na folha de rodar) — ink neutro.
            fieldLabel("Operador")
            TextField("quem autoriza esta parada", text: $actor)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaPremiumStopActor)
            fieldLabel("Motivo")
            TextField("por que parar agora (fica no recibo)", text: $reason, axis: .vertical)
                .lineLimit(2...4)
                .modifier(ArenaFieldChrome(minHeight: 88))
                .accessibilityIdentifier(A11yID.arenaPremiumStopReason)
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .atlasSans(12, .medium)
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private var receipt: some View {
        if let value = model.lastStopReceipt,
           value.measurementIdPublic == run.measurementIdPublic {
            VStack(alignment: .leading, spacing: 6) {
                Label(
                    value.accepted ? "Solicitação confirmada" : "Medição já havia terminado",
                    systemImage: value.accepted ? "checkmark.seal" : "info.circle"
                )
                    .font(AtlasFont.serif(15, .semibold))
                    .foregroundStyle(value.accepted ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
                Text(value.stopsAfterCurrentCase ? "Parada após o caso atual" : value.status.rawValue)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .accessibilityIdentifier(A11yID.arenaPremiumStopReceipt)
        }
        if let error = model.controlError {
            Text(error)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.alert)
        }
    }

    private var confirm: some View {
        Button {
            guard let measurementId = run.measurementIdPublic else { return }
            // Medium: governed stop commits operator actor+reason.
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            Task {
                await model.stopMeasurement(
                    measurementId: measurementId,
                    operatorActor: actor,
                    operatorReason: reason
                )
            }
        } label: {
            HStack(spacing: 9) {
                ArenaPremiumIcon(
                    symbol: ArenaPremiumIconography.stop,
                    tone: valid && !isConfirmed ? .negative : .muted
                )
                Text(model.isStoppingMeasurement ? "Solicitando…" : "Parar após o caso atual")
            }
                .font(AtlasFont.serif(16, .semibold))
                .frame(maxWidth: .infinity, minHeight: 52)
                .foregroundStyle(valid && !isConfirmed ? AtlasTheme.alert : AtlasTheme.textTertiary)
                .background(Capsule().fill(AtlasTheme.alert.opacity(valid && !isConfirmed ? 0.08 : 0.03)))
                .overlay(Capsule().stroke(AtlasTheme.alert.opacity(valid && !isConfirmed ? 0.5 : 0.15), lineWidth: 1))
                .atlasElevation(radius: 8, y: 2, opacity: valid && !isConfirmed ? 0.14 : 0.06)
        }
        .buttonStyle(PressableScale())
        .disabled(!valid || model.isStoppingMeasurement || isConfirmed)
        .accessibilityIdentifier(A11yID.arenaPremiumStopConfirm)
        .accessibilityLabel(
            isConfirmed
                ? "parada já confirmada"
                : (valid ? "parar após o caso atual" : "parar indisponível, preencha operador e motivo")
        )
        .accessibilityHint(
            valid && !isConfirmed
                ? "solicita parada governada após o caso em andamento"
                : ""
        )
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(valid && !isConfirmed ? 9 : 0)
    }
}


struct ArenaPremiumDestinationView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(AtlasSession.self) private var session
    let target: ArenaPremiumDestination
    @Bindable var model: ArenaModel
    let onStop: (AtlasArenaLiveRun) -> Void
    let onSuite: (AtlasArenaSuite) -> Void
    @State private var showingAsk = false
    @State private var askThreadId: ThreadID?
    @State private var askDraft = ""

    var body: some View {
        ScrollView {
            destinationContent
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 18)
                .padding(.bottom, 108)
        }
        .scrollIndicators(.hidden)
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg.opacity(0.92), AtlasTheme.bg],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 28)
                .allowsHitTesting(false)
                AgenticPill(
                    invite: ArenaPremiumAskContext.invite(tab: .now, destination: target),
                    accessibilityId: A11yID.arenaPremiumAskPill
                ) {
                    askDraft = ""
                    showingAsk = true
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: $showingAsk) {
            ConversationView(
                client: session.client,
                threadId: askThreadId,
                title: "Arena · \(title)",
                emptyPrompt: ArenaPremiumAskContext.invite(tab: .now, destination: target),
                emptySuggestions: ArenaPremiumAskContext.emptySuggestions(tab: .now, destination: target),
                taskKind: "arena",
                workspace: nil,
                draft: askDraft,
                turnFacts: { [model, target] _ in
                    ArenaPremiumAskContext.facts(model: model, tab: .now, destination: target)
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

    @ViewBuilder
    private var destinationContent: some View {
        switch target {
        case .execution:
            ArenaPremiumExecutionView(model: model, onStop: onStop)
        case .plan:
            ArenaPremiumPlanView(model: model)
        case .queue:
            ArenaPremiumQueueView(model: model)
        case .alerts:
            ArenaPremiumAlertsView(model: model, onSuite: onSuite)
        case .results:
            ArenaPremiumResultsView(
                model: model,
                reduceMotion: reduceMotion,
                onSuite: onSuite
            )
        }
    }

    private var title: String {
        switch target {
        case .execution: "Execução"
        case .plan: "Plano"
        case .queue: "Fila"
        case .alerts: "Alertas"
        case .results: "Motor"
        }
    }
}


struct ArenaPremiumPlanView: View {
    @Bindable var model: ArenaModel

    private var liveRuns: [AtlasArenaLiveRun] {
        // União medição + fila (dedup por suíte+braço): o Plano nunca fica
        // mais magro que a Fila, mesmo se o measurementId não casar em toda
        // corrida enfileirada. Corridas vivas primeiro, fila depois.
        var seen = Set<String>()
        return (model.arenaPrimaryMeasurementRuns + (model.livePresentation?.queuedRuns ?? []))
            .compactMap { run in
                seen.insert("\(run.suite)|\(run.arm?.rawValue ?? "")").inserted ? run : nil
            }
    }

    private var liveSuites: [String] {
        var seen = Set<String>()
        return liveRuns.compactMap { seen.insert($0.suite).inserted ? $0.suite : nil }
    }

    private var liveArmsText: String {
        var seen = Set<String>()
        return liveRuns.compactMap(\.arm)
            .compactMap { seen.insert($0.rawValue).inserted ? $0.labelPT : nil }
            .joined(separator: " → ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumKicker(text: "Ordem de medição")
                .accessibilityIdentifier(A11yID.arenaPremiumPlan)
            Text("Plano")
                .font(AtlasFont.serif(36))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if let plan = model.activePlan {
                headline(engines: plan.engines.count, suites: plan.suites.count,
                         arms: plan.arms.count, runs: plan.runsPlanned)
                suiteSequence(plan.suites,
                              armsText: plan.arms.map(\.labelPT).joined(separator: " → "),
                              footer: "A seleção enviada pode avançar; casos concluídos não são reabertos.")
            } else if !liveSuites.isEmpty {
                // Medição viva sem plano explícito (veio do servidor): a
                // medição É o plano — derivar das corridas reais. Dizer
                // "nenhum plano" com suítes na fila era a contradição.
                headline(engines: Set(liveRuns.map(\.engineDisplayName)).count,
                         suites: liveSuites.count,
                         arms: Set(liveRuns.compactMap { $0.arm?.rawValue }).count,
                         runs: liveRuns.count)
                suiteSequence(liveSuites,
                              armsText: liveArmsText,
                              footer: "Ordem derivada da medição em curso; casos concluídos não são reabertos.")
            } else {
                empty
            }
        }
    }

    private func headline(engines: Int, suites: Int, arms: Int, runs: Int) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 28) {
                metric(engines, "motores")
                metric(suites, "suítes")
                metric(arms, "braços")
                metric(runs, "corridas")
            }
            VStack(alignment: .leading, spacing: 12) {
                metric(engines, "motores")
                metric(suites, "suítes")
                metric(runs, "corridas")
            }
        }
    }

    private func suiteSequence(_ suites: [String], armsText: String, footer: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ArenaPremiumHairline()
            ForEach(Array(suites.enumerated()), id: \.element) { index, suite in
                HStack(spacing: 14) {
                    Text(String(format: "%02d", index + 1))
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .frame(width: 28, alignment: .leading)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(ArenaDisplay.suite(suite))
                            .atlasSans(16, .medium)
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Text(armsText)
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textSecondary)
                    }
                    Spacer()
                    ArenaPremiumIcon(
                        symbol: ArenaPremiumIconography.planStatus(planStatus(suite)),
                        tone: planTone(suite)
                    )
                }
                .padding(.vertical, 14)
                .accessibilityIdentifier(A11yID.arenaPremiumPlanRow(suite))
                ArenaPremiumHairline()
            }
            Text(footer)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.top, 16)
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 16) {
            ArenaPremiumEmptyGlyph(symbol: "list.bullet.rectangle")
            Text("Nenhum plano ativo")
                .font(AtlasFont.serif(29))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("Crie uma medição para organizar suítes, motores e braços.")
                .font(AtlasFont.serif(15))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Nenhum plano ativo. Crie uma medição para organizar suítes, motores e braços."
        )
        .accessibilityIdentifier(A11yID.arenaPremiumState("plan-empty"))
    }

    private func metric(_ value: Int, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(value)").font(AtlasFont.serif(30)).foregroundStyle(AtlasTheme.textPrimary)
            Text(label).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func planStatus(_ suite: String) -> AtlasArenaRunStatus? {
        let statuses = model.arenaPrimaryMeasurementRuns.filter { $0.suite == suite }.map(\.status)
        if statuses.contains(.running) { return .running }
        if statuses.contains(.stopping) { return .stopping }
        if statuses.contains(.queued) { return .queued }
        if statuses.contains(.failed) { return .failed }
        if !statuses.isEmpty, statuses.allSatisfy({ $0 == .completed }) { return .completed }
        if statuses.contains(.stopped) { return .stopped }
        return nil
    }

    private func planTone(_ suite: String) -> ArenaPremiumTone {
        switch planStatus(suite) {
        case .running, .stopping, .queued: .active
        case .completed: .positive
        case .failed: .negative
        case .stopped, .unknown, nil: .neutral
        }
    }

}

struct ArenaPremiumQueueView: View {
    @Bindable var model: ArenaModel

    private var queued: [AtlasArenaLiveRun] {
        model.livePresentation?.queuedRuns ?? []
    }

    private var queuedSuites: [String] {
        var seen = Set<String>()
        return queued.compactMap { seen.insert($0.suite).inserted ? $0.suite : nil }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumKicker(text: "Aguardando execução", tone: queued.isEmpty ? .neutral : .active, showsLiveMark: !queued.isEmpty)
                .accessibilityIdentifier(A11yID.arenaPremiumQueue)
            HStack(alignment: .lastTextBaseline) {
                Text("\(queuedSuites.count)")
                    .font(AtlasFont.serif(58))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(queuedSuites.count == 1 ? "suíte na fila" : "suítes na fila")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            // Sem rodapé-manual: o kicker "aguardando execução" + o relógio
            // por linha já dizem o estado — meta-copy é ruído.
            queueRows
        }
    }

    private var queueRows: some View {
        VStack(spacing: 0) {
            ArenaPremiumHairline()
            ForEach(Array(queuedSuites.enumerated()), id: \.element) { index, suite in
                HStack(spacing: 14) {
                    Text("\(index + 1)")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .frame(width: 26, alignment: .leading)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ArenaDisplay.suite(suite))
                            .atlasSans(16, .medium)
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Text(queueDetail(suite))
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textSecondary)
                    }
                    Spacer()
                    ArenaPremiumIcon(symbol: "clock", tone: .muted)
                }
                .padding(.vertical, 14)
                .accessibilityIdentifier(A11yID.arenaPremiumQueueRow(suite))
                ArenaPremiumHairline()
            }
            if queued.isEmpty {
                Text("Fila vazia")
                    .font(AtlasFont.serif(15))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
            }
        }
    }

    private func queueDetail(_ suite: String) -> String {
        let runs = queued.filter { $0.suite == suite }
        // Dedup dos braços: 2 motores × 2 braços rendia "sem Atlas · com
        // Atlas · sem Atlas · com Atlas" (a quebra da Fila) — cada braço uma vez.
        var seenArms = Set<String>()
        let arms = runs.compactMap(\.arm)
            .compactMap { seenArms.insert($0.rawValue).inserted ? $0.labelPT : nil }
        let engine = runs.first.map { ArenaDisplay.engine($0.engineDisplayName) }
        return ([engine] + arms).compactMap(\.self).joined(separator: " · ")
    }
}


/// Frota medida — ranking editorial de todos os motores (com vs sem Atlas).
/// Dados: `composite.engines` apenas; ausência = “não medido”, nunca zero.
struct ArenaPremiumFleetView: View {
    @Bindable var model: ArenaModel

    private var engines: [AtlasArenaCompositeEngine] {
        let raw = model.composite?.engines ?? []
        return raw.sorted { lhs, rhs in
            switch (lhs.atlasMultiplier, rhs.atlasMultiplier) {
            case let (l?, r?): return l > r
            case (_?, nil): return true
            case (nil, _?): return false
            case (nil, nil):
                switch (lhs.composite, rhs.composite) {
                case let (l?, r?): return l > r
                case (_?, nil): return true
                case (nil, _?): return false
                default: return lhs.engine < rhs.engine
                }
            }
        }
    }

    private var best: AtlasArenaCompositeEngine? {
        engines.first { $0.atlasMultiplier != nil && ($0.atlasMultiplier ?? 0) > 0 }
            ?? engines.first { $0.composite != nil }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            header
            if engines.isEmpty {
                empty
            } else {
                ForEach(engines) { engine in
                    fleetRow(engine, highlight: engine.id == best?.id)
                }
            }
        }
        .accessibilityIdentifier(A11yID.arenaPremiumFleet)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: "Frota medida · \(engines.count) \(engines.count == 1 ? "motor" : "motores")"
            )
            Text("Onde o Atlas sobe")
                .font(AtlasFont.serif(31))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if let best, let mult = best.atlasMultiplier {
                Text("Melhor ganho · \(ArenaDisplay.engine(best.engine)) · \(ArenaFormat.multiplier(mult))")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.accent)
            }
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 14) {
            ArenaPremiumEmptyGlyph(symbol: "gauge.with.dots.needle.33percent")
            Text("Nenhum motor medido")
                .font(AtlasFont.serif(28))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("Rode uma medição com pelo menos um motor para ver o ranking da frota.")
                .font(AtlasFont.serif(15))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Nenhum motor medido. Rode uma medição com pelo menos um motor para ver o ranking da frota.")
        .accessibilityIdentifier(A11yID.arenaPremiumState("fleet-empty"))
    }

    private func fleetRow(_ engine: AtlasArenaCompositeEngine, highlight: Bool) -> some View {
        let without = engine.withoutAtlasComposite
        let withAtlas = engine.withAtlasComposite
        let maxScore = max(without ?? 0, withAtlas ?? 0, 10)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(ArenaDisplay.engine(engine.engine))
                    .atlasSans(15, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                multiplierLabel(engine)
            }
            if without != nil || withAtlas != nil {
                bar(label: "sem", value: without, ceiling: maxScore, atlas: false)
                bar(label: "Atlas", value: withAtlas, ceiling: maxScore, atlas: true)
            } else {
                Text("Não medido")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            ArenaPremiumHairline()
        }
        .padding(.top, highlight ? 2 : 0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(fleetSpoken(engine))
        .accessibilityIdentifier(A11yID.arenaPremiumFleetRow(engine.engine))
    }

    @ViewBuilder
    private func multiplierLabel(_ engine: AtlasArenaCompositeEngine) -> some View {
        if let mult = engine.atlasMultiplier {
            Text(ArenaFormat.multiplier(mult))
                .font(AtlasFont.mono(11, .medium))
                .foregroundStyle(mult >= 1 ? AtlasTheme.accent : AtlasTheme.alert)
        } else if engine.composite == nil {
            Text("Não medido")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }

    private func bar(label: String, value: Double?, ceiling: Double, atlas: Bool) -> some View {
        let fraction: CGFloat = {
            guard let value, ceiling > 0 else { return 0 }
            return CGFloat(min(Swift.max(value / ceiling, 0), 1))
        }()
        return HStack(spacing: 10) {
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(width: 44, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AtlasTheme.textPrimary.opacity(0.06))
                        .frame(height: 2)
                    Capsule()
                        .fill(atlas ? AtlasTheme.accent : AtlasTheme.textSecondary.opacity(0.55))
                        .frame(width: Swift.max(geo.size.width * fraction, value == nil ? 0 : 2), height: 2)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 14)
            Text(ArenaFormat.score(value))
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 36, alignment: .trailing)
        }
        .accessibilityHidden(true)
    }

    private func fleetSpoken(_ engine: AtlasArenaCompositeEngine) -> String {
        let name = ArenaDisplay.engine(engine.engine)
        if let mult = engine.atlasMultiplier {
            return "\(name), multiplicador \(ArenaFormat.multiplier(mult)), sem Atlas \(ArenaFormat.score(engine.withoutAtlasComposite)), com Atlas \(ArenaFormat.score(engine.withAtlasComposite))"
        }
        return "\(name), Não medido"
    }
}


struct ArenaPremiumAlertsView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var model: ArenaModel
    let onSuite: (AtlasArenaSuite) -> Void

    private var reportAlertSuites: Set<String> {
        Set(reportAlerts.map(\.suite))
    }

    private var regressions: [AtlasArenaSuite] {
        model.scoreboard?.suites.filter {
            $0.hasRegression && !reportAlertSuites.contains($0.suite)
        } ?? []
    }

    private var reportAlerts: [AtlasArenaReportSuite] {
        model.report?.attentionSuites ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumKicker(
                text: hasAlerts ? "Exceções que pedem atenção" : "Sem exceções",
                tone: hasAlerts ? .negative : .positive
            )
            .accessibilityIdentifier(A11yID.arenaPremiumAlerts)
            HStack(alignment: .lastTextBaseline, spacing: 7) {
                Text("\(regressions.count + reportAlerts.count)")
                    .font(AtlasFont.serif(58))
                    .foregroundStyle(hasAlerts ? AtlasTheme.alert : AtlasTheme.textPrimary)
                Text("Alertas")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            alertRows
            blockers
        }
    }

    private var alertRows: some View {
        VStack(spacing: 0) {
            ArenaPremiumHairline()
            ForEach(regressions) { suite in
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onSuite(suite)
                } label: {
                    alertRow(
                        title: ArenaDisplay.suite(suite.suite),
                        detail: regressionDetail(suite),
                        symbol: "arrow.down.right"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    "\(ArenaDisplay.suite(suite.suite)), \(regressionDetail(suite))"
                )
                .accessibilityHint("Abre a suíte com regressão")
                .accessibilityAddTraits(.isButton)
                ArenaPremiumHairline()
            }
            ForEach(reportAlerts) { report in
                alertRow(
                    title: ArenaDisplay.suite(report.suite),
                    detail: report.status.displayPT,
                    symbol: "exclamationmark.triangle"
                )
                ArenaPremiumHairline()
            }
            if !hasAlerts {
                HStack(spacing: 10) {
                    ArenaPremiumIcon(
                        symbol: ArenaPremiumIconography.coverage,
                        tone: .positive
                    )
                    Text("Nenhuma regressão ou falha publicada")
                }
                    .font(AtlasFont.serif(15))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity, minHeight: 86, alignment: .leading)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Nenhuma regressão ou falha publicada")
                    .accessibilityIdentifier(A11yID.arenaPremiumState("alerts-empty"))
            }
        }
    }

    @ViewBuilder
    private var blockers: some View {
        if let blockers = model.report?.claimBlockers, !blockers.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                ArenaPremiumKicker(text: "Publicação bloqueada")
                ForEach(blockers, id: \.self) { blocker in
                    HStack(spacing: 8) {
                        ArenaPremiumIcon(
                            symbol: ArenaPremiumIconography.blocked,
                            tone: .neutral,
                            role: .compact
                        )
                        Text(publicBlocker(blocker))
                    }
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
            }
        }
    }

    private var hasAlerts: Bool { !regressions.isEmpty || !reportAlerts.isEmpty }

    private func alertRow(title: String, detail: String, symbol: String) -> some View {
        HStack(spacing: 14) {
            ArenaPremiumIcon(symbol: symbol, tone: .negative)
            Text(title)
                .atlasSans(16, .medium)
                .foregroundStyle(AtlasTheme.textPrimary)
            Spacer()
            Text(detail)
                .font(AtlasFont.mono(10, .medium))
                .foregroundStyle(AtlasTheme.alert)
                .multilineTextAlignment(.trailing)
            ArenaPremiumChevron()
        }
        .frame(minHeight: 58)
        .contentShape(Rectangle())
    }

    private func regressionDetail(_ suite: AtlasArenaSuite) -> String {
        let delta = suite.engines.first(where: \.regressed)?.delta
        return "\(ArenaFormat.signed(delta)) · regressão"
    }

    private func publicBlocker(_ raw: String) -> String {
        switch raw {
        case "missing_data": "há dados incompletos"
        case "pipeline_invalid": "a validação do pipeline falhou"
        case "suite_failed": "uma suíte não concluiu"
        default: "resultado ainda não pode ser afirmado"
        }
    }
}


struct ArenaPremiumNowView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var model: ArenaModel
    let onRun: () -> Void
    let onNavigate: (ArenaPremiumDestination) -> Void
    let onStop: (AtlasArenaLiveRun) -> Void

    var body: some View {
        Group {
            if model.composite == nil, isPreparing {
                loading
            } else {
                nowState
            }
        }
    }

    private var isPreparing: Bool {
        switch model.phase {
        case .idle, .loading: true
        case .loaded, .failed: false
        }
    }

    @ViewBuilder
    private var nowState: some View {
        switch model.livePresentation?.phase ?? .idle {
        case .running:
            ArenaPremiumRunningView(
                model: model,
                onNavigate: onNavigate,
                onStop: onStop
            )
        case .stopping:
            ArenaPremiumTerminalView(
                model: model,
                kind: .stopping,
                onRun: onRun,
                onNavigate: onNavigate
            )
        case .queued:
            ArenaPremiumQueuedView(model: model, onNavigate: onNavigate)
        case .completed:
            ArenaPremiumTerminalView(
                model: model,
                kind: .completed,
                onRun: onRun,
                onNavigate: onNavigate
            )
        case .failed:
            ArenaPremiumTerminalView(
                model: model,
                kind: .failed,
                onRun: onRun,
                onNavigate: onNavigate
            )
        case .stopped:
            ArenaPremiumTerminalView(
                model: model,
                kind: .stopped,
                onRun: onRun,
                onNavigate: onNavigate
            )
        case .idle:
            ArenaPremiumIdleView(model: model, onRun: onRun, onNavigate: onNavigate)
        }
    }

    private var loading: some View {
        VStack(alignment: .leading, spacing: 22) {
            ArenaPremiumKicker(text: "Preparando a Arena", tone: .active, showsDot: true)
            Text("Organizando as medições")
                .font(AtlasFont.serif(32))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            loadingIndicator
            Text("Índice, execução e capacidades chegam por contratos independentes.")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 24)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Preparando a Arena. Organizando as medições.")
        .accessibilityAddTraits(reduceMotion ? .isStaticText : [.isStaticText, .updatesFrequently])
        .accessibilityIdentifier(A11yID.arenaPremiumState("loading"))
    }

    @ViewBuilder
    private var loadingIndicator: some View {
        if reduceMotion {
            Text("Carregando…")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        } else {
            ProgressView()
                .tint(AtlasTheme.accent)
                .accessibilityHidden(true)
        }
    }
}


struct ArenaPremiumRunningView: View {
    @Bindable var model: ArenaModel
    let onNavigate: (ArenaPremiumDestination) -> Void
    let onStop: (AtlasArenaLiveRun) -> Void

    private var run: AtlasArenaLiveRun? { model.arenaPrimaryRun }
    private var progress: AtlasArenaLiveProgress? { model.livePresentation?.progress }
    private var percentage: Int? {
        progress.flatMap { $0.completed == 0 ? nil : Int(($0.fraction * 100).rounded(.down)) }
    }

    /// Nunca “Motor desconhecido”: se o live run veio sem engine, usa o
    /// preferido / composto. O string literal do Core é falha de wire, não UX.
    private var engineTitle: String { model.arenaLiveEngineTitle }

    private var subtitle: String {
        [run.map { ArenaDisplay.suite($0.suite) }, run?.arm?.labelPT]
            .compactMap(\.self)
            .joined(separator: " · ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            identity
            progressHero
            actions
            ArenaPremiumComparison(model: model, provisional: true)
            ArenaPremiumOperationalRows(model: model, onNavigate: onNavigate)
        }
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(text: "Ao vivo", tone: .active, showsLiveMark: true)
                .accessibilityIdentifier(A11yID.arenaPremiumState("running"))
            Text(engineTitle)
                .font(AtlasFont.serif(31))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
                .accessibilityAddTraits(.isHeader)
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            subtitle.isEmpty
                ? "Ao vivo, \(engineTitle)"
                : "Ao vivo, \(engineTitle), \(subtitle)"
        )
    }

    private var progressHero: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 24) {
                ArenaPremiumProgressRing(progress: progress?.fraction, percentage: percentage)
                progressCopy
                    .frame(minHeight: 142, alignment: .center)
            }
            VStack(alignment: .leading, spacing: 14) {
                ArenaPremiumProgressRing(progress: progress?.fraction, percentage: percentage)
                progressCopy
            }
        }
    }

    private var progressCopy: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let progress {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(progress.completed)")
                        .font(AtlasFont.serif(28))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text("/ \(progress.total)")
                        .font(AtlasFont.serif(18))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                Text("Casos confirmados")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
                Text("\(progress.remaining) restantes")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.top, 2)
            } else {
                Text("Progresso indeterminado")
                    .font(AtlasFont.mono(13, .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("Denominador ainda não publicado")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(progressSpoken)
    }

    private var progressSpoken: String {
        if let progress {
            return "\(progress.completed) de \(progress.total) casos confirmados, \(progress.remaining) restantes"
        }
        return "Progresso indeterminado, denominador ainda não publicado"
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumAction(title: "Ver execução", tone: .neutral) {
                onNavigate(.execution)
            }
            .accessibilityIdentifier(A11yID.arenaPremiumExecutionAction)
            if let run,
               run.canStop == true,
               run.measurementIdPublic != nil {
                ArenaPremiumAction(title: "Parar após o caso atual", quiet: true) {
                    onStop(run)
                }
                .accessibilityIdentifier(A11yID.arenaPremiumStop)
            }
        }
    }
}


struct ArenaPremiumIdleView: View {
    @Bindable var model: ArenaModel
    let onRun: () -> Void
    let onNavigate: (ArenaPremiumDestination) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ArenaPremiumEmptyGlyph(symbol: "scope")
                .accessibilityIdentifier(A11yID.arenaPremiumState("idle"))
            ArenaPremiumKicker(text: "Arena pronta")
            Text("Nada medindo agora")
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("Escolha os motores, as suítes e os braços. A Arena cuida da ordem e mostra apenas progresso confirmado.")
                .font(AtlasFont.serif(16))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(
                    "Escolha os motores, as suítes e os braços. A Arena cuida da ordem e mostra apenas progresso confirmado."
                )
            ArenaPremiumAction(title: "Rodar medição", symbol: "play.fill", action: onRun)
            if model.arenaPrimaryEngine != nil {
                ArenaPremiumHairline()
                ArenaPremiumKicker(text: "Último resultado")
                ArenaPremiumDisclosureRow(
                    title: ArenaDisplay.engine(model.arenaPrimaryEngine?.engine ?? "motor"),
                    detail: model.arenaCoverageText,
                    symbol: "chart.line.uptrend.xyaxis",
                    tone: .neutral
                ) { onNavigate(.results) }
            }
        }
    }
}

struct ArenaPremiumQueuedView: View {
    @Bindable var model: ArenaModel
    let onNavigate: (ArenaPremiumDestination) -> Void

    private var queuedRuns: [AtlasArenaLiveRun] {
        model.livePresentation?.queuedRuns ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumKicker(text: "Na fila", tone: .active, showsDot: true)
                .accessibilityIdentifier(A11yID.arenaPremiumState("queued"))
            Text("Medição programada")
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(model.arenaLiveEngineTitle)
                .font(AtlasFont.mono(14))
                .foregroundStyle(AtlasTheme.textSecondary)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 28) {
                    queuedMetric("\(Set(queuedRuns.map(\.suite)).count)", "suítes")
                    queuedMetric("\(queuedRuns.count)", "corridas")
                    queuedMetric("\(Set(queuedRuns.compactMap { $0.arm?.rawValue }).count)", "braços")
                }
                VStack(alignment: .leading, spacing: 14) {
                    queuedMetric("\(Set(queuedRuns.map(\.suite)).count)", "suítes")
                    queuedMetric("\(queuedRuns.count)", "corridas")
                }
            }
            Text("Ainda não iniciado · nenhum progresso foi presumido.")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
            ArenaPremiumAction(title: "Ver execução", tone: .neutral) {
                onNavigate(.execution)
            }
            ArenaPremiumOperationalRows(model: model, onNavigate: onNavigate)
        }
    }

    private func queuedMetric(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value).font(AtlasFont.serif(32)).foregroundStyle(AtlasTheme.textPrimary)
            Text(label).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(value) \(label)")
    }
}

enum ArenaPremiumTerminalKind: Equatable {
    case stopping
    case stopped
    case completed
    case failed
}

struct ArenaPremiumTerminalView: View {
    @Bindable var model: ArenaModel
    let kind: ArenaPremiumTerminalKind
    let onRun: () -> Void
    let onNavigate: (ArenaPremiumDestination) -> Void

    private var configuration: (String, String, String, ArenaPremiumTone) {
        switch kind {
        case .stopping:
            ("Parada solicitada", "Finalizando o caso atual", "hourglass", .active)
        case .stopped:
            ("Medição parada", "Resultados parciais preservados", "stop.circle", .neutral)
        case .completed:
            ("Medição concluída", "Resultado terminal confirmado", "checkmark.seal", .positive)
        case .failed:
            ("Medição interrompida", "O que concluiu foi preservado", "exclamationmark.triangle", .negative)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumEmptyGlyph(symbol: configuration.2, tone: configuration.3)
                .accessibilityIdentifier(A11yID.arenaPremiumState(stateIdentifier))
            ArenaPremiumKicker(text: configuration.0, tone: configuration.3)
            Text(model.arenaLiveEngineTitle)
                .font(AtlasFont.serif(33))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(configuration.1)
                .font(AtlasFont.serif(16))
                .foregroundStyle(AtlasTheme.textSecondary)
            if let progress = model.livePresentation?.progress {
                HStack(alignment: .lastTextBaseline, spacing: 7) {
                    Text("\(progress.completed)")
                        .font(AtlasFont.serif(44))
                    Text("de \(progress.total) casos confirmados")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(progress.completed) de \(progress.total) casos confirmados")
            }
            if kind == .failed {
                Text(publicFailureCopy)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.alert)
            }
            terminalActions
            ArenaPremiumOperationalRows(model: model, onNavigate: onNavigate)
        }
    }

    @ViewBuilder
    private var terminalActions: some View {
        if kind == .stopping {
            ArenaPremiumAction(
                title: "Parando…",
                symbol: "hourglass",
                tone: .active,
                disabled: true,
                action: {}
            )
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    ArenaPremiumAction(title: "Ver resultados", symbol: "chart.xyaxis.line", tone: .neutral) {
                        onNavigate(.results)
                    }
                    ArenaPremiumAction(title: "Rodar novamente", symbol: "arrow.clockwise", tone: .neutral, action: onRun)
                }
                VStack(alignment: .leading, spacing: 10) {
                    ArenaPremiumAction(title: "Ver resultados", symbol: "chart.xyaxis.line", tone: .neutral) {
                        onNavigate(.results)
                    }
                    ArenaPremiumAction(title: "Rodar novamente", symbol: "arrow.clockwise", tone: .neutral, action: onRun)
                }
            }
        }
    }

    private var publicFailureCopy: String {
        switch model.arenaPrimaryRun?.failureCode {
        case "with_atlas_runtime_unsupported": "este motor não suporta o braço com Atlas"
        case "plan_failed": "o plano da suíte não pôde ser preparado"
        case "native_execution_failed": "a execução nativa não concluiu"
        case "pipeline_failed": "a consolidação da medição falhou"
        case "internal_error": "falha interna classificada pelo servidor"
        default: "falha classificada pelo servidor"
        }
    }

    private var stateIdentifier: String {
        switch kind {
        case .stopping: "stopping"
        case .stopped: "stopped"
        case .completed: "completed"
        case .failed: "failed"
        }
    }
}


/// Agora ao vivo: zero inventário. Só o que o operador precisa agora —
/// progresso, um verbo (Ver execução), par se existir, alerta se doer.
struct ArenaPremiumOperationalRows: View {
    @Bindable var model: ArenaModel
    let onNavigate: (ArenaPremiumDestination) -> Void

    private var alertCount: Int { model.arenaAlertSuiteCount }

    var body: some View {
        // Sem exceção: some a seção. Fila/Cobertura/Próxima/Plano moram
        // DENTRO de Execução — duplicar aqui era a confusão.
        if alertCount > 0 {
            VStack(spacing: 0) {
                ArenaPremiumHairline()
                ArenaPremiumGlyphRow(
                    glyph: "※",
                    title: "Alertas",
                    detail: alertCount == 1 ? "1 exceção" : "\(alertCount) exceções",
                    tone: .negative,
                    glyphTone: .negative
                ) { onNavigate(.alerts) }
                .accessibilityIdentifier(A11yID.arenaPremiumAlertsAction)
            }
        }
    }
}


struct ArenaPremiumResultsView: View {
    @Bindable var model: ArenaModel
    let reduceMotion: Bool
    let onSuite: (AtlasArenaSuite) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            if let engine = model.arenaPrimaryEngine {
                resultHeader(engine)
                resultMetrics(engine)
                if !engine.history.isEmpty {
                    ArenaPremiumKicker(text: "Índice por rodada")
                    ArenaCompositeChart(engine: engine, reduceMotion: reduceMotion)
                        .frame(height: 190)
                }
                suiteList
            } else {
                empty
            }
        }
    }

    private var measuredEngineOptions: [String] {
        model.composite?.engines.map(\.engine) ?? []
    }

    private func resultHeader(_ engine: AtlasArenaCompositeEngine) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: model.report?.claimAllowed == true ? "Última medição concluída" : "Medição parcial"
            )
            .accessibilityIdentifier(A11yID.arenaPremiumResults)
            ArenaPremiumEngineTitle(
                engineID: engine.engine,
                options: measuredEngineOptions,
                onSelect: { model.capabilitiesEngineSelection = $0 }
            )
            if let narrative = model.report?.narrative {
                Text(narrative)
                    .font(AtlasFont.serif(15))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func resultMetrics(_ engine: AtlasArenaCompositeEngine) -> some View {
        let atlasDelta = pairedDelta(engine)
        return VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Índice").font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(ArenaFormat.score(engine.composite))
                            .font(AtlasFont.serif(62))
                        Text("/10")
                            .font(AtlasFont.mono(13, .medium))
                            .foregroundStyle(AtlasTheme.textSecondary)
                    }
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(ArenaFormat.score(engine.composite)) de 10")
                }
                Spacer()
                if let atlasDelta {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(ArenaFormat.signed(atlasDelta))
                            .font(AtlasFont.serifItalic(18))
                            .foregroundStyle(atlasDelta >= 0 ? AtlasTheme.accent : AtlasTheme.alert)
                        Text("vs. sem Atlas")
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textSecondary)
                    }
                }
            }
            ArenaPremiumHairline()
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 28) {
                    smallMetric("Sem Atlas", ArenaFormat.score(engine.withoutAtlasComposite))
                    smallMetric("Com Atlas", ArenaFormat.score(engine.withAtlasComposite), tone: .active)
                    smallMetric("Multiplicador", ArenaFormat.multiplier(engine.atlasMultiplier), tone: .active)
                }
                VStack(alignment: .leading, spacing: 12) {
                    smallMetric("Sem Atlas", ArenaFormat.score(engine.withoutAtlasComposite))
                    smallMetric("Com Atlas", ArenaFormat.score(engine.withAtlasComposite), tone: .active)
                    smallMetric("Multiplicador", ArenaFormat.multiplier(engine.atlasMultiplier), tone: .active)
                }
            }
            Text("Cobertura \(model.arenaCoverageText) · \(model.report?.claimAllowed == true ? "resultado final" : "resultado parcial")")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private var suiteList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ArenaPremiumKicker(text: "Por suíte")
                .padding(.bottom, 8)
            ForEach(model.scoreboard?.suites ?? []) { suite in
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onSuite(suite)
                } label: {
                    HStack(spacing: 13) {
                        ArenaPremiumIcon(
                            symbol: ArenaPremiumIconography.suite(suite.suite),
                            tone: suite.hasRegression ? .negative : .neutral
                        )
                        Text(ArenaDisplay.suite(suite.suite))
                            .font(AtlasFont.serif(17))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Spacer()
                        suiteMetric(suite)
                        ArenaPremiumChevron()
                    }
                    .frame(minHeight: 54)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(ArenaDisplay.suite(suite.suite))
                .accessibilityHint(
                    suite.hasRegression
                        ? "abre a suíte com regressão"
                        : "abre o detalhe da suíte"
                )
                .accessibilityIdentifier(A11yID.arenaPremiumResultSuite(suite.suite))
                .accessibilityAddTraits(.isButton)
                ArenaPremiumHairline()
            }
            Text("Resultados ausentes aparecem como não medidos, nunca como zero.")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.top, 16)
        }
    }

    @ViewBuilder
    private func suiteMetric(_ suite: AtlasArenaSuite) -> some View {
        if let engine = suite.engines.first(where: { $0.engine == model.arenaSelectedEngineID })
            ?? suite.engines.first {
            HStack(spacing: 6) {
                Text(ArenaFormat.score(engine.score))
                    .foregroundStyle(AtlasTheme.textPrimary)
                if let delta = engine.delta {
                    Text(ArenaFormat.signed(delta))
                        .foregroundStyle(delta < 0 ? AtlasTheme.alert : (delta > 0 ? AtlasTheme.textPrimary : AtlasTheme.textSecondary))
                }
            }
            .font(AtlasFont.mono(11, .medium))
        } else {
            Text("Não medido")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }

    private func smallMetric(
        _ label: String,
        _ value: String,
        tone: ArenaPremiumTone = .neutral
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textSecondary)
            Text(value).font(AtlasFont.mono(18, .medium)).foregroundStyle(tone.color)
        }
    }

    private func pairedDelta(_ engine: AtlasArenaCompositeEngine) -> Double? {
        guard let withAtlas = engine.withAtlasComposite,
              let withoutAtlas = engine.withoutAtlasComposite else { return nil }
        return withAtlas - withoutAtlas
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 18) {
            ArenaPremiumEmptyGlyph(symbol: "chart.xyaxis.line")
            Text("Nenhum resultado medido")
                .font(AtlasFont.serif(31))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("O primeiro resultado aparecerá quando uma suíte concluir.")
                .font(AtlasFont.serif(16))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Nenhum resultado medido. O primeiro resultado aparecerá quando uma suíte concluir."
        )
        .accessibilityIdentifier(A11yID.arenaPremiumState("results-empty"))
    }
}



/// Gráfico de histórico do índice (composto / com Atlas / sem Atlas).
struct ArenaCompositeChart: View {
    let engine: AtlasArenaCompositeEngine
    let reduceMotion: Bool

    private var interpolation: InterpolationMethod { reduceMotion ? .linear : .catmullRom }

    /// Domínio ajustado ao dado: eixo fixo 0–1 espremia as linhas.
    private var fittedYDomain: ClosedRange<Double> {
        let values = engine.history.flatMap { [$0.composite, $0.withAtlas, $0.withoutAtlas].compactMap { $0 } }
        guard let lo = values.min(), let hi = values.max(), hi > lo else { return 0 ... 1 }
        let pad = max(0.04, (hi - lo) * 0.3)
        return max(0, lo - pad) ... min(1, hi + pad)
    }

    var body: some View {
        Chart {
            ForEach(engine.history) { point in
                if let composite = point.composite {
                    LineMark(
                        x: .value("rodada", point.roundAt),
                        y: .value("composto", composite)
                    )
                    .foregroundStyle(AtlasTheme.accent)
                    .interpolationMethod(interpolation)
                }
                if let withAtlas = point.withAtlas {
                    LineMark(
                        x: .value("rodada", point.roundAt),
                        y: .value("com Atlas", withAtlas),
                        series: .value("série", "com Atlas")
                    )
                    .foregroundStyle(AtlasTheme.accent.opacity(0.65))
                    .interpolationMethod(interpolation)
                }
                if let withoutAtlas = point.withoutAtlas {
                    LineMark(
                        x: .value("rodada", point.roundAt),
                        y: .value("sem Atlas", withoutAtlas),
                        series: .value("série", "sem Atlas")
                    )
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .interpolationMethod(interpolation)
                }
            }
        }
        .chartLegend(.visible)
        .chartXAxis(.hidden)
        .chartYScale(domain: fittedYDomain)
        .chartYAxis { AxisMarks(position: .leading) }
        .accessibilityHidden(true)
    }
}

// Cycle 046 fused ArenaComposite+UI.swift

extension AtlasArenaCompositeEngine {
    /// Cobertura incompleta — casca só rotula «parcial» com prova do contrato.
    var isPartialCoverage: Bool {
        coverage < 1.0
    }
}


struct ArenaPremiumComparison: View {
    @Bindable var model: ArenaModel
    let provisional: Bool

    /// Par publicado: suíte da corrida → qualquer suíte do motor → composto.
    private var pair: PublishedPair? {
        if let suiteEngine = suiteEnginePair,
           let without = suiteEngine.withoutAtlasScore,
           let withAtlas = suiteEngine.withAtlasScore {
            return PublishedPair(
                without: without,
                withAtlas: withAtlas,
                source: .suite
            )
        }
        if let engine = model.arenaPrimaryEngine,
           let without = engine.withoutAtlasComposite,
           let withAtlas = engine.withAtlasComposite {
            return PublishedPair(without: without, withAtlas: withAtlas, source: .composite)
        }
        return nil
    }

    private var suiteEnginePair: AtlasArenaSuiteEngine? {
        let engineID = resolvedEngineID
        let suites = model.scoreboard?.suites ?? []
        if let run = model.arenaPrimaryRun {
            if let match = suites.first(where: { $0.suite == run.suite })?
                .engines.first(where: { engineMatches($0.engine, engineID) }),
               match.withoutAtlasScore != nil,
               match.withAtlasScore != nil {
                return match
            }
        }
        // Último par publicado do mesmo motor (suíte da corrida pode ainda
        // não ter scoreboard — a medição ao vivo não apaga o histórico).
        return suites
            .flatMap(\.engines)
            .first {
                engineMatches($0.engine, engineID)
                    && $0.withoutAtlasScore != nil
                    && $0.withAtlasScore != nil
            }
    }

    private var resolvedEngineID: String? {
        if let engine = model.arenaPrimaryRun?.engine, !engine.isEmpty { return engine }
        return model.preferredEngine ?? model.arenaPrimaryEngine?.engine
    }

    var body: some View {
        Group {
            if let pair {
                VStack(alignment: .leading, spacing: 12) {
                    ArenaPremiumHairline()
                    ArenaPremiumKicker(text: kickerTitle(for: pair))
                    values(pair)
                }
            }
            // Sem par publicado: some a seção inteira — kicker órfão era mentira
            // visual (título sem 6,0 → 7,6).
        }
    }

    private func kickerTitle(for pair: PublishedPair) -> String {
        switch pair.source {
        case .suite:
            return provisional ? "Último par · escala 0–10" : "Comparação final · escala 0–10"
        case .composite:
            return provisional ? "Índice do motor · escala 0–10" : "Comparação final · escala 0–10"
        }
    }

    private func values(_ pair: PublishedPair) -> some View {
        let delta = pair.withAtlas - pair.without
        return HStack(alignment: .lastTextBaseline, spacing: 14) {
            metric(ArenaFormat.score(pair.without), "Sem Atlas", gold: false)
            Text("→")
                .font(AtlasFont.serif(15))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.bottom, 2)
                .accessibilityHidden(true)
            metric(ArenaFormat.score(pair.withAtlas), "Com Atlas", gold: true)
            Spacer(minLength: 4)
            Text(ArenaFormat.signed(delta))
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(
                    abs(delta) < 0.005
                        ? AtlasTheme.textSecondary
                        : (delta > 0 ? AtlasTheme.accent : AtlasTheme.alert)
                )
                .padding(.bottom, 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Sem Atlas \(ArenaFormat.score(pair.without)), com Atlas \(ArenaFormat.score(pair.withAtlas)), diferença \(ArenaFormat.signed(delta))"
        )
    }

    private func metric(_ value: String, _ label: String, gold: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(AtlasFont.serif(12, .semibold))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(value)
                .font(AtlasFont.serif(28))
                .foregroundStyle(gold ? AtlasTheme.accent : AtlasTheme.textPrimary)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value)")
    }

    private func engineMatches(_ candidate: String, _ expected: String?) -> Bool {
        guard let expected, !expected.isEmpty else { return true }
        return candidate == expected
    }

    private struct PublishedPair {
        enum Source { case suite, composite }
        let without: Double
        let withAtlas: Double
        let source: Source
    }
}


/// Execução = o ÚNICO mapa da medição (mockup operador 2026-07-20).
/// Pipeline macro + casos da suíte ao vivo + corridas tocáveis.
struct ArenaPremiumExecutionView: View {
    @Bindable var model: ArenaModel
    let onStop: (AtlasArenaLiveRun) -> Void

    private var runs: [AtlasArenaLiveRun] { model.arenaPrimaryMeasurementRuns }
    private var primary: AtlasArenaLiveRun? { model.arenaPrimaryRun }

    private var orderedRuns: [AtlasArenaLiveRun] {
        let live = runs.filter { $0.status == .running || $0.status == .stopping }
        let done = runs.filter {
            $0.status == .completed || $0.status == .failed || $0.status == .stopped
        }
        let upcoming = runs.filter { $0.status == .queued }
        return live + done + upcoming
    }

    private var pipeline: ArenaPremiumPipelineProjection {
        let planArms = model.activePlan?.arms ?? []
        return .project(
            runs: runs,
            expectsBare: planArms.contains(.baseline) || runs.contains { $0.arm == .baseline },
            expectsAtlas: planArms.contains(.withAtlas) || runs.contains { $0.arm == .withAtlas },
            hasReport: model.report != nil
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
                .accessibilityIdentifier(A11yID.arenaPremiumExecution)
            nowBlock
            if canStop {
                ArenaPremiumAction(title: "Parar após o caso atual", quiet: true) {
                    if let primary { onStop(primary) }
                }
            }
            ArenaPremiumHairline()
            ArenaPremiumExecutionPipeline(projection: pipeline)
            ArenaPremiumHairline()
            corridas
        }
    }

    private var canStop: Bool {
        guard let primary else { return false }
        return primary.canStop == true && primary.measurementIdPublic != nil
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: statusLabel,
                tone: statusTone,
                showsLiveMark: statusTone == .active
            )
            Text(model.arenaLiveEngineTitle)
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("Ordem, estado e progresso confirmados pelo servidor.")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(statusLabel), \(model.arenaLiveEngineTitle)")
    }

    @ViewBuilder
    private var nowBlock: some View {
        if let primary {
            let casesDone = primary.casesDone
            let casesTotal = primary.casesTotal
            if let casesDone, let casesTotal, casesTotal > 0 {
                caseHero(
                    done: min(casesDone, casesTotal),
                    total: casesTotal,
                    fraction: Double(min(max(0, casesDone), casesTotal)) / Double(casesTotal),
                    suiteLine: suiteLine(primary)
                )
            } else if let progress = model.livePresentation?.progress {
                caseHero(
                    done: progress.completed,
                    total: progress.total,
                    fraction: progress.fraction,
                    suiteLine: suiteLine(primary)
                )
            } else {
                Text("Casos ainda sem denominador nesta corrida.")
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityLabel("Casos ainda sem denominador nesta corrida.")
            }
        } else if runs.isEmpty {
            Text("Nenhuma corrida nesta medição.")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityLabel("Nenhuma corrida nesta medição.")
                .accessibilityIdentifier(A11yID.arenaPremiumState("execution-empty"))
        }
    }

    private func caseHero(done: Int, total: Int, fraction: Double, suiteLine: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(done)")
                    .font(AtlasFont.serif(52))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("de \(total) casos")
                    .font(AtlasFont.serif(22))
                    .foregroundStyle(AtlasTheme.textSecondary)
                Spacer()
                Text("\(Int((fraction * 100).rounded(.down)))%")
                    .font(AtlasFont.mono(18, .medium))
                    .foregroundStyle(AtlasTheme.accent)
            }
            Text(suiteLine)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func suiteLine(_ run: AtlasArenaLiveRun) -> String {
        [ArenaDisplay.suite(run.suite), run.arm?.labelPT]
            .compactMap(\.self)
            .joined(separator: " · ")
    }

    private var corridas: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Corridas")
                .font(AtlasFont.mono(10, .medium))
                .tracking(0.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
                .padding(.bottom, 10)
            if orderedRuns.isEmpty {
                Text("Ainda sem corridas publicadas.")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityLabel("Ainda sem corridas publicadas.")
            } else {
                ForEach(orderedRuns) { run in
                    NavigationLink {
                        ArenaPremiumRunDetailView(run: run)
                    } label: {
                        runRow(run)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(.isButton)
                    ArenaPremiumHairline()
                }
            }
        }
    }

    private func runRow(_ run: AtlasArenaLiveRun) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 14) {
            Text(rowGlyph(run))
                .font(AtlasFont.serif(14))
                .foregroundStyle(tone(run.status).color)
                .frame(width: 22, alignment: .center)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(ArenaDisplay.suite(run.suite))
                    .atlasSans(16, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(rowDetail(run))
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            Spacer(minLength: 8)
            Text(rowTrailing(run))
                .font(AtlasFont.mono(11, .medium))
                .foregroundStyle(tone(run.status).color)
                .multilineTextAlignment(.trailing)
            ArenaPremiumChevron()
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .accessibilityIdentifier(A11yID.arenaPremiumExecutionRun(run.runIdPublic))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(ArenaDisplay.suite(run.suite)), \(run.arm?.labelPT ?? ""), \(rowTrailing(run))"
        )
        .accessibilityHint("Abre os casos desta corrida")
    }

    /// Ao vivo = ▸ (rodando). Nunca ✦ do Atlas nas corridas.
    private func rowGlyph(_ run: AtlasArenaLiveRun) -> String {
        switch run.status {
        case .running, .stopping: "▸"
        case .completed: "✓"
        case .failed: "※"
        case .queued: "◷"
        case .stopped, .unknown: "·"
        }
    }

    private func rowDetail(_ run: AtlasArenaLiveRun) -> String {
        if let done = run.casesDone, let total = run.casesTotal, total > 0 {
            return "\(done)/\(total) casos"
        }
        return run.arm?.labelPT ?? run.status.displayPT
    }

    private func rowTrailing(_ run: AtlasArenaLiveRun) -> String {
        let arm = run.arm?.labelPT
        let state: String = switch run.status {
        case .running: "ao vivo"
        case .stopping: "parando"
        case .queued: "na fila"
        case .completed: "concluída"
        case .failed: "falhou"
        case .stopped: "parada"
        case .unknown: run.status.displayPT
        }
        return [state, arm].compactMap(\.self).joined(separator: " · ")
    }

    private var statusLabel: String {
        switch model.livePresentation?.phase ?? .idle {
        case .idle: "Sem execução"
        case .queued: "Na fila"
        case .running: "Ao vivo"
        case .stopping: "Parando"
        case .stopped: "Parada"
        case .completed: "Concluída"
        case .failed: "Interrompida"
        }
    }

    private var statusTone: ArenaPremiumTone {
        switch model.livePresentation?.phase ?? .idle {
        case .running, .queued, .stopping: .active
        case .completed: .positive
        case .failed: .negative
        case .idle, .stopped: .neutral
        }
    }

    private func tone(_ status: AtlasArenaRunStatus) -> ArenaPremiumTone {
        switch status {
        case .queued, .running, .stopping: .active
        case .completed: .positive
        case .failed: .negative
        case .stopped, .unknown: .neutral
        }
    }
}


/// Detalhe de uma corrida: progresso + casos (lista real = §5 Core).
struct ArenaPremiumRunDetailView: View {
    let run: AtlasArenaLiveRun

    private var fraction: Double? {
        guard let done = run.casesDone, let total = run.casesTotal, total > 0 else { return nil }
        return Double(min(max(0, done), total)) / Double(total)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                progressBlock
                casesBlock
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 18)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle(ArenaDisplay.suite(run.suite))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier(A11yID.arenaPremiumRunDetail)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: statusLabel,
                tone: statusTone,
                showsLiveMark: run.status == .running || run.status == .stopping
            )
            Text(ArenaDisplay.suite(run.suite))
                .font(AtlasFont.serif(28))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if let arm = run.arm?.labelPT {
                Text(arm)
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
    }

    @ViewBuilder
    private var progressBlock: some View {
        if let done = run.casesDone, let total = run.casesTotal, total > 0, let fraction {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    Text("\(min(done, total))")
                        .font(AtlasFont.serif(44))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text("de \(total) casos")
                        .font(AtlasFont.serif(18))
                        .foregroundStyle(AtlasTheme.textSecondary)
                    Spacer()
                    Text("\(Int((fraction * 100).rounded(.down)))%")
                        .font(AtlasFont.mono(16, .medium))
                        .foregroundStyle(AtlasTheme.accent)
                }
                Text(summaryLine(done: min(done, total), total: total))
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        } else {
            Text("Denominador de casos ainda não publicado nesta corrida.")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private var casesBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Casos")
                .font(AtlasFont.mono(10, .medium))
                .tracking(0.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
            Text("Lista por teste ainda não publicada pelo servidor. Quando o contrato chegar, cada caso aparece aqui — feitos, ao vivo e a seguir.")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityIdentifier(A11yID.arenaPremiumRunDetailCases)
    }

    private func summaryLine(done: Int, total: Int) -> String {
        let remaining = max(0, total - done)
        switch run.status {
        case .running, .stopping:
            return "\(done) confirmados · 1 em andamento · \(max(0, remaining - 1)) a seguir"
        case .queued:
            return "\(total) na fila · ainda não iniciado"
        case .completed:
            return "\(done) de \(total) concluídos"
        case .failed:
            return "\(done) de \(total) antes da falha"
        case .stopped:
            return "\(done) de \(total) quando parou"
        case .unknown:
            return "\(done) de \(total)"
        }
    }

    private var statusLabel: String {
        switch run.status {
        case .running: "Ao vivo"
        case .stopping: "Parando"
        case .queued: "Na fila"
        case .completed: "Concluída"
        case .failed: "Falhou"
        case .stopped: "Parada"
        case .unknown: "Estado"
        }
    }

    private var statusTone: ArenaPremiumTone {
        switch run.status {
        case .running, .stopping, .queued: .active
        case .completed: .positive
        case .failed: .negative
        case .stopped, .unknown: .neutral
        }
    }
}


/// Fase macro da medição — presentation-only, derivada dos runs vivos.
enum ArenaPremiumPipelineStep: Int, CaseIterable, Identifiable {
    case prepare
    case bare
    case withAtlas
    case consolidate

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .prepare: "Preparar"
        case .bare: "Sem Atlas"
        case .withAtlas: "Com Atlas"
        case .consolidate: "Consolidar"
        }
    }
}

enum ArenaPremiumPipelineMark {
    case pending
    case live
    case done
}

struct ArenaPremiumPipelineProjection: Equatable {
    let marks: [ArenaPremiumPipelineStep: ArenaPremiumPipelineMark]

    static func project(
        runs: [AtlasArenaLiveRun],
        expectsBare: Bool,
        expectsAtlas: Bool,
        hasReport: Bool
    ) -> ArenaPremiumPipelineProjection {
        var marks: [ArenaPremiumPipelineStep: ArenaPremiumPipelineMark] = [:]
        let bare = runs.filter { $0.arm == .baseline }
        let atlas = runs.filter { $0.arm == .withAtlas }
        let anyLive = runs.contains { $0.status == .running || $0.status == .stopping }
        let allQueued = !runs.isEmpty && runs.allSatisfy { $0.status == .queued }
        let allTerminal = !runs.isEmpty && runs.allSatisfy(Self.isTerminal)

        if runs.isEmpty {
            marks[.prepare] = .pending
        } else if allQueued {
            marks[.prepare] = .live
        } else {
            marks[.prepare] = .done
        }

        marks[.bare] = armMark(
            bare,
            expected: expectsBare || !bare.isEmpty,
            prepareDone: marks[.prepare] == .done
        )
        marks[.withAtlas] = armMark(
            atlas,
            expected: expectsAtlas || !atlas.isEmpty,
            prepareDone: marks[.prepare] == .done
        )

        if allTerminal {
            marks[.consolidate] = hasReport ? .done : .live
        } else if anyLive || allQueued {
            marks[.consolidate] = .pending
        } else {
            marks[.consolidate] = .pending
        }

        return ArenaPremiumPipelineProjection(marks: marks)
    }

    private static func armMark(
        _ armRuns: [AtlasArenaLiveRun],
        expected: Bool,
        prepareDone: Bool
    ) -> ArenaPremiumPipelineMark {
        guard expected else { return prepareDone ? .done : .pending }
        if armRuns.contains(where: { $0.status == .running || $0.status == .stopping }) {
            return .live
        }
        if !armRuns.isEmpty, armRuns.allSatisfy(isTerminal) {
            return .done
        }
        return .pending
    }

    private static func isTerminal(_ run: AtlasArenaLiveRun) -> Bool {
        switch run.status {
        case .completed, .failed, .stopped: true
        default: false
        }
    }
}

struct ArenaPremiumExecutionPipeline: View {
    let projection: ArenaPremiumPipelineProjection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pipeline")
                .font(AtlasFont.mono(10, .medium))
                .tracking(0.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
            HStack(alignment: .top, spacing: 0) {
                ForEach(ArenaPremiumPipelineStep.allCases) { step in
                    stepColumn(step)
                    if step != .consolidate {
                        pipelineRail(after: step)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spoken)
        .accessibilityIdentifier(A11yID.arenaPremiumExecutionPipeline)
    }

    private func stepColumn(_ step: ArenaPremiumPipelineStep) -> some View {
        let mark = projection.marks[step] ?? .pending
        return VStack(spacing: 8) {
            Text(glyph(step, mark))
                .font(AtlasFont.serif(14))
                .foregroundStyle(color(mark))
                .frame(height: 20)
            Text(step.title)
                .font(AtlasFont.mono(9, .medium))
                .foregroundStyle(mark == .pending ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private func pipelineRail(after step: ArenaPremiumPipelineStep) -> some View {
        let done = (projection.marks[step] ?? .pending) == .done
        return Rectangle()
            .fill(done ? AtlasTheme.separator : AtlasTheme.separator.opacity(0.35))
            .frame(width: 18, height: 1)
            .padding(.top, 10)
            .accessibilityHidden(true)
    }

    /// Corrida ao vivo usa ▸; ✦ só na fase cujo nome é Atlas.
    private func glyph(_ step: ArenaPremiumPipelineStep, _ mark: ArenaPremiumPipelineMark) -> String {
        switch mark {
        case .done: "✓"
        case .pending: "○"
        case .live:
            step == .withAtlas ? "✦" : "▸"
        }
    }

    private func color(_ mark: ArenaPremiumPipelineMark) -> Color {
        switch mark {
        case .live: AtlasTheme.accent
        case .done: AtlasTheme.textPrimary
        case .pending: AtlasTheme.textTertiary
        }
    }

    private var spoken: String {
        ArenaPremiumPipelineStep.allCases.map { step in
            let mark = projection.marks[step] ?? .pending
            let state: String = switch mark {
            case .done: "feito"
            case .live: "ao vivo"
            case .pending: "pendente"
            }
            return "\(step.title) \(state)"
        }.joined(separator: ", ")
    }
}


struct ArenaPremiumCapabilitiesView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var model: ArenaModel
    let onCapability: (AtlasArenaCapability) -> Void

    private var capabilities: [AtlasArenaCapability] {
        model.selectedCapabilities?.capabilities ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            capabilityHeader
            if capabilities.isEmpty {
                empty
            } else {
                summary
                trackLegend
                rows
            }
        }
        // Ao abrir a aba, re-busca do servidor: o poll de 10s não recarrega
        // capacidades, então sem isto a tela ficava com dado velho (o -8,3
        // falso onde o servidor já diz "não medido").
        .task { await model.refreshCapabilities() }
    }

    private var capabilityHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(text: "Perfil medido · escala 0–10")
                .accessibilityIdentifier(A11yID.arenaPremiumCapabilities)
            ArenaPremiumEngineTitle(
                engineID: model.selectedCapabilities?.engine
                    ?? model.preferredEngine
                    ?? "motor",
                options: model.capabilityEngineOptions,
                onSelect: { model.capabilitiesEngineSelection = $0 }
            )
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(measuredCount)")
                    .font(AtlasFont.serif(56))
                Text("/\(capabilities.count)")
                    .font(AtlasFont.serif(29))
                Text("Capacidades cobertas")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .padding(.leading, 6)
            }
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(measuredCount) de \(capabilities.count) capacidades cobertas")
        }
    }

    private var trackLegend: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Circle()
                    .stroke(AtlasTheme.textSecondary, lineWidth: 1.5)
                    .frame(width: 8, height: 8)
                Text("Sem Atlas")
            }
            HStack(spacing: 5) {
                Text("✦")
                    .font(AtlasFont.serif(11))
                    .foregroundStyle(AtlasTheme.accent)
                Text("Com Atlas")
            }
        }
        .font(AtlasFont.mono(10))
        .foregroundStyle(AtlasTheme.textTertiary)
        .accessibilityHidden(true)
    }

    private var summary: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 24) {
                summaryMetric(improvedCount, "melhoraram", .positive)
                summaryMetric(stableCount, "estáveis", .neutral)
                summaryMetric(regressedCount, "regrediram", .negative)
            }
            VStack(alignment: .leading, spacing: 10) {
                summaryMetric(improvedCount, "melhoraram", .positive)
                summaryMetric(stableCount, "estáveis", .neutral)
                summaryMetric(regressedCount, "regrediram", .negative)
            }
        }
    }

    /// Ordem fixa dos grupos da taxonomia v2 — decisão editorial, não alfabética:
    /// construir → compreender → manter → operar.
    private static let groupOrder = ["construction", "comprehension", "quality", "agentic"]

    private var rows: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let area = model.selectedCapabilities?.areaLabelPt, !area.isEmpty {
                Text(area)
                    .font(AtlasFont.mono(10, .medium))
                    .tracking(0.4)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.bottom, 10)
            }
            ForEach(Self.groupOrder, id: \.self) { groupKey in
                let members = capabilities.filter { ($0.group ?? "quality") == groupKey }
                if !members.isEmpty {
                    Text(model.selectedCapabilities?.groupsPt?[groupKey] ?? groupKey)
                        .font(AtlasFont.serif(17))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .padding(.top, 14)
                        .padding(.bottom, 4)
                    groupRows(members)
                }
            }
            Text(capabilitiesCaption)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.top, 16)
        }
    }

    private func groupRows(_ members: [AtlasArenaCapability]) -> some View {
        VStack(spacing: 0) {
            ArenaPremiumHairline()
            ForEach(members) { capability in
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onCapability(capability)
                } label: {
                    // Sem numeral: a lista não é sequência — número que não
                    // codifica nada é ruído (régua da casa).
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(capability.labelPt)
                                .font(AtlasFont.serif(15))
                                .foregroundStyle(AtlasTheme.textPrimary)
                            if let caption = shortConfidence(capability) {
                                Text(caption)
                                    .font(AtlasFont.mono(9))
                                    .foregroundStyle(AtlasTheme.textTertiary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                        .frame(maxWidth: 170, alignment: .leading)
                        ArenaCapabilityTrack(
                            baseline: capability.score,
                            withAtlas: capability.withAtlas
                        )
                        .frame(minWidth: 86)
                        deltaLabel(capability)
                        ArenaPremiumChevron()
                    }
                    .frame(minHeight: 58)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(capabilitySpoken(capability))
                .accessibilityHint("Abre o detalhe desta capacidade")
                .accessibilityIdentifier(A11yID.arenaCapabilityRow(capability.capability))
                .accessibilityAddTraits(.isButton)
                ArenaPremiumHairline()
            }
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 16) {
            ArenaPremiumEmptyGlyph(symbol: "shield.lefthalf.filled")
            Text("Capacidades ainda não medidas")
                .font(AtlasFont.serif(29))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("Ausência permanece ausência — nenhuma barra começa em zero.")
                .font(AtlasFont.serif(15))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Capacidades ainda não medidas. Ausência permanece ausência — nenhuma barra começa em zero."
        )
        .accessibilityIdentifier(A11yID.arenaPremiumState("capabilities-empty"))
    }

    private var capabilitiesCaption: String {
        if model.capabilityEngineOptions.count > 1 {
            return "Toque no nome do motor para ver outro perfil medido. Cada capacidade abre as suítes que alimentaram a medida."
        }
        return "Cada capacidade abre as suítes e os casos que contribuíram para a medida."
    }

    // Lei do operador: número não confiável = não medido, nunca falso. "Coberta"
    // aqui significa MEDIDA com confiança — ter dois pontos na régua não basta
    // (o +4,9 de code_editing com 81% do braço Atlas descartado era exatamente
    // um número de sobrevivência vendido como vitória no topo da tela).
    private var measuredCount: Int {
        capabilities.count { $0.confidenceLevel == .measured }
    }

    // Melhorou/regrediu SÓ com IC de Newcombe fora do zero; medido sem
    // significância é "estável" (dentro do ruído), nunca vitória nem derrota.
    private var improvedCount: Int {
        capabilities.count { $0.confidenceLevel == .measured && $0.delta?.significant == true && ($0.delta?.value ?? 0) > 0 }
    }

    private var regressedCount: Int {
        capabilities.count { $0.confidenceLevel == .measured && $0.delta?.significant == true && ($0.delta?.value ?? 0) < 0 }
    }

    private var stableCount: Int { max(0, measuredCount - improvedCount - regressedCount) }

    private func delta(_ capability: AtlasArenaCapability) -> Double? {
        capability.delta?.value
    }

    /// Sub-rótulo honesto para linha que NÃO é medida — a mesma verdade que a
    /// aba clássica fala via confidenceCaption, na densidade da lista premium.
    private func shortConfidence(_ capability: AtlasArenaCapability) -> String? {
        // Capacidade gated: instrumento em preparação — a razão É a informação.
        if let gated = capability.gatedReason, !gated.isEmpty {
            return gated
        }
        switch capability.confidenceLevel {
        case .measured:
            return capability.delta?.significant == true ? nil : "dentro do ruído"
        case .low:
            let n = capability.withAtlasCases ?? capability.baselineCases ?? 0
            return "poucos casos (N \(n)) · baixa confiança"
        case .unmeasured:
            if let rate = capability.maxExclusionRate, rate >= 0.5 {
                return "\(Int((rate * 100).rounded()))% descartado no setup · não medível"
            }
            return capability.withAtlas == nil ? "Atlas ainda não rodou aqui" : "não medível"
        }
    }

    private func summaryMetric(_ value: Int, _ label: String, _ tone: ArenaPremiumTone) -> some View {
        HStack(spacing: 6) {
            Text("\(value)").font(AtlasFont.serif(25)).foregroundStyle(tone.color)
            Text(label).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func deltaLabel(_ capability: AtlasArenaCapability) -> some View {
        // Delta como NOTA só quando medido; não-medível vira travessão (o ponto
        // na régua continua visível, mas nenhum número finge veredito).
        let level = capability.confidenceLevel
        let text = level == .unmeasured ? "—" : ArenaFormat.signed(delta(capability))
        return Text(text)
            .font(AtlasFont.mono(10, .medium))
            .foregroundStyle(deltaColor(capability))
            .frame(width: 44, alignment: .trailing)
    }

    private func deltaColor(_ capability: AtlasArenaCapability) -> Color {
        switch capability.confidenceLevel {
        case .unmeasured, .low:
            return AtlasTheme.textTertiary
        case .measured:
            guard capability.delta?.significant == true, let value = delta(capability) else {
                return AtlasTheme.textSecondary
            }
            return value > 0 ? AtlasTheme.textPrimary : AtlasTheme.alert
        }
    }

    private func capabilitySpoken(_ capability: AtlasArenaCapability) -> String {
        let base = "\(capability.labelPt), sem Atlas \(ArenaFormat.score(capability.score)), com Atlas \(ArenaFormat.score(capability.withAtlas)), diferença \(ArenaFormat.signed(delta(capability)))"
        guard let caption = shortConfidence(capability) else { return base }
        return "\(base), \(caption)"
    }
}

struct ArenaCapabilityTrack: View {
    let baseline: Double?
    let withAtlas: Double?

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(AtlasTheme.separator).frame(height: 2)
                // sem Atlas = anel quieto; com Atlas = ✦ da casa (não bola).
                if let baseline {
                    Circle()
                        .fill(AtlasTheme.bg)
                        .overlay(Circle().stroke(AtlasTheme.textSecondary, lineWidth: 1.5))
                        .frame(width: 10, height: 10)
                        .offset(x: max(0, min(w - 10, w * baseline - 5)))
                }
                if let withAtlas {
                    Text("✦")
                        .font(AtlasFont.serif(13))
                        .foregroundStyle(AtlasTheme.accent)
                        .offset(x: max(0, min(w - 13, w * withAtlas - 6.5)))
                }
            }
        }
        .frame(height: 18)
        .accessibilityHidden(true)
    }
}


struct ArenaPremiumCapabilityDetail: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let capability: AtlasArenaCapability
    let scoreboard: AtlasArenaScoreboard?
    let engineId: String?

    private var delta: Double? {
        guard let baseline = capability.score, let withAtlas = capability.withAtlas else { return nil }
        return withAtlas - baseline
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumKicker(text: "Capacidade medida · escala 0–10")
                        .accessibilityIdentifier(A11yID.arenaPremiumCapabilityDetail)
                    Text(capability.labelPt)
                        .font(AtlasFont.serif(34))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    comparison
                    contribution
                    provenance
                }
                .padding(AtlasTheme.Space.screen)
            }
            .scrollIndicators(.hidden)
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Capacidade")
            .navigationBarTitleDisplayMode(.inline)
            // Contain: title, comparison and provenance stay separately focusable.
            .accessibilityElement(children: .contain)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AtlasCloseToolbarButton(
                        spokenLabel: "fechar capacidade",
                        spokenHint: "volta para o perfil",
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
            }
        }
    }

    private var comparison: some View {
        VStack(alignment: .leading, spacing: 18) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 30) {
                    metric("Sem Atlas", capability.score)
                    ArenaPremiumIcon(
                        symbol: ArenaPremiumIconography.comparison,
                        tone: .muted,
                        role: .compact
                    )
                    metric("Com Atlas", capability.withAtlas, tone: .active)
                    Spacer()
                    Text(ArenaFormat.signed(delta))
                        .font(AtlasFont.mono(16, .medium))
                        .foregroundStyle(deltaColor)
                }
                VStack(alignment: .leading, spacing: 14) {
                    metric("Sem Atlas", capability.score)
                    metric("Com Atlas", capability.withAtlas, tone: .active)
                    Text("Diferença \(ArenaFormat.signed(delta))")
                        .font(AtlasFont.mono(12, .medium))
                        .foregroundStyle(deltaColor)
                }
            }
            ArenaCapabilityTrack(baseline: capability.score, withAtlas: capability.withAtlas)
                .frame(height: 24)
        }
    }

    private var contribution: some View {
        VStack(alignment: .leading, spacing: 0) {
            ArenaPremiumKicker(text: "Suítes que contribuíram")
                .padding(.bottom, 10)
            ArenaPremiumHairline()
            ForEach(capability.suitesContributing, id: \.self) { suite in
                HStack {
                    ArenaPremiumIcon(
                        symbol: ArenaPremiumIconography.suite(suite)
                    )
                    Text(ArenaDisplay.suite(suite))
                        .atlasSans(16, .medium)
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Spacer()
                    Text(suiteCases(suite))
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                .padding(.vertical, 14)
                ArenaPremiumHairline()
            }
        }
    }

    private var provenance: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(text: "Proveniência")
            // "denominador" é jargão de estatístico — português direto.
            Text("\(capability.casesTotal.map(String.init) ?? "—") casos somados na conta publicada")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
            Text("Ausência de um braço permanece não medida.")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }

    private var deltaColor: Color {
        guard let delta else { return AtlasTheme.textTertiary }
        if abs(delta) <= 0.005 { return AtlasTheme.textSecondary }
        return delta > 0 ? AtlasTheme.textPrimary : AtlasTheme.alert
    }

    private func metric(_ label: String, _ value: Double?, tone: ArenaPremiumTone = .neutral) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(ArenaFormat.score(value))
                .font(AtlasFont.serif(34))
                .foregroundStyle(tone.color)
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func suiteCases(_ suite: String) -> String {
        guard let engines = scoreboard?.suites.first(where: { $0.suite == suite })?.engines,
              let total = (engines.first(where: { $0.engine == engineId }) ?? engines.first)?
                .casesTotal else { return "casos não publicados" }
        return "\(total) casos"
    }
}


// Cycle 044 fuse → ArenaRunSheet.swift

extension ArenaRunSheet {
    var runScrollBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 8) {
                    ArenaPremiumKicker(text: "Nova medição", tone: .active)
                    Text("O que vamos medir?")
                        .font(AtlasFont.serif(34))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Text("Escolha somente o necessário. A ordem e o progresso aparecem na Arena assim que o servidor confirmar.")
                        .font(AtlasFont.serif(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                formSections
                planPreview
                statusBlocks
                submitButton
            }
            .padding(AtlasTheme.Space.screen)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.lastStartReceipt?.receiptHash)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.controlError)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle("Rodar medição")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { runToolbar }
    }

    @ViewBuilder
    private var planPreview: some View {
        if !selectedSuites.isEmpty, !selectedEngines.isEmpty, !selectedArms.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                ArenaPremiumKicker(text: "Plano")
                Text(
                    "\(selectedEngines.count) \(selectedEngines.count == 1 ? "motor" : "motores") · "
                        + "\(selectedSuites.count) \(selectedSuites.count == 1 ? "suíte" : "suítes") · "
                        + "\(selectedEngines.count * selectedSuites.count * selectedArms.count) corridas"
                )
                .font(AtlasFont.mono(11, .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                Text(selectedArms.sorted { $0.rawValue < $1.rawValue }.map(\.labelPT).joined(separator: " → "))
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .padding(.vertical, 4)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "Plano, \(selectedEngines.count) motores, \(selectedSuites.count) suítes, "
                    + "\(selectedEngines.count * selectedSuites.count * selectedArms.count) corridas, "
                    + selectedArms.sorted { $0.rawValue < $1.rawValue }.map(\.labelPT).joined(separator: ", ")
            )
        }
    }
}

struct ArenaRunSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Bindable var model: ArenaModel
    @State var selectedSuites: Set<String> = []
    /// Multi-select (goal 1: motor contra motor) — cada motor vira um POST B5.
    @State var selectedEngines: Set<String> = []
    @State var selectedArms: Set<AtlasArenaRunArm> = [.baseline, .withAtlas]
    @State var actor = ""
    @State var reason = ""

    var body: some View {
        runSheetA11y(runNavShell)
            .onChange(of: model.lastStartReceipt?.receiptHash) { _, hash in
                guard hash != nil else { return }
                AtlasMotion.successNotification(reduceMotion: reduceMotion)
            }
    }
}

extension ArenaRunSheet {
    var runNavShell: some View {
        NavigationStack {
            runScrollBody
        }
    }
}

extension ArenaRunSheet {
    @ToolbarContentBuilder
    var runToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            AtlasCloseToolbarButton(
                spokenLabel: spokenCloseLabel(),
                spokenHint: spokenCloseHint(),
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}

extension ArenaRunSheet {
    func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ArenaPremiumKicker(text: title)
                .accessibilityAddTraits(.isHeader)
            content()
                .padding(.leading, 2)
        }
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var statusBlocks: some View {
        if let error = model.controlError {
            Text(error)
                .font(AtlasFont.serif(15))
                .foregroundStyle(AtlasTheme.alert)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(AtlasTheme.alert.opacity(0.08), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
                .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.alert.opacity(0.28), lineWidth: 1))
                .atlasElevation(radius: 6, y: 2, opacity: 0.1)
                .accessibilityLabel(spokenErrorLabel(error))
                .transition(reduceMotion ? .identity : .opacity)
        }
        if let receipt = model.lastStartReceipt {
            receiptCard(receipt)
                .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 8)))
        }
    }
}

extension ArenaRunSheet {
    func seedDefaultsIfNeeded() {
        if selectedSuites.isEmpty, let first = installedSuites.first?.suite {
            selectedSuites.insert(first)
        }
        if engines.isEmpty {
            selectedEngines = []
        } else if selectedEngines.isEmpty, let first = engines.first {
            selectedEngines = [first]
        }
    }
}

extension ArenaRunSheet {
    func spokenSubmitLabel(input: AtlasArenaStartInput, enginesEmpty: Bool) -> String {
        if input.isLocallyValidForSubmission {
            return spokenSubmitValid()
        }
        if enginesEmpty {
            return spokenSubmitEnginesEmpty()
        }
        return spokenSubmitMissing(input: input)
    }
}

extension ArenaRunSheet {
    func spokenEmptyEngines() -> String {
        "nenhum motor publicado pelo servidor, rodar medição indisponível"
    }

    func spokenEmptySuites() -> String {
        "nenhuma suite com adapter instalado, rodar medição indisponível"
    }
}

extension ArenaRunSheet {
    func spokenErrorLabel(_ message: String) -> String {
        "erro: \(message)"
    }
}

extension ArenaRunSheet {
    func spokenSubmitHint(input: AtlasArenaStartInput, enginesEmpty: Bool) -> String {
        if input.isLocallyValidForSubmission {
            return "envia medição governada ao servidor"
        }
        if enginesEmpty {
            return "aguarde o servidor publicar pelo menos um motor"
        }
        return "preencha ator, motivo, suites, motor e braços"
    }
}

extension ArenaRunSheet {
    func spokenActorHint() -> String {
        "nome de quem autoriza a medição"
    }

    func spokenReasonHint() -> String {
        "motivo auditável registrado no ledger"
    }
}

extension ArenaRunSheet {
    func spokenSubmitMissingOperator(input: AtlasArenaStartInput) -> [String] {
        var missing: [String] = []
        if input.operatorActor.isEmpty { missing.append("ator") }
        if input.operatorReason.isEmpty { missing.append("motivo auditável") }
        return missing
    }
}

extension ArenaRunSheet {
    func spokenSubmitMissingSuite(input: AtlasArenaStartInput) -> [String] {
        var missing: [String] = []
        if input.suites.selectedValues.isEmpty { missing.append("suites") }
        if input.engine.isEmpty { missing.append("motor") }
        if input.arms.isEmpty { missing.append("braços") }
        return missing
    }
}

extension ArenaRunSheet {
    func spokenSubmitMissing(input: AtlasArenaStartInput) -> String {
        let missing = spokenSubmitMissingOperator(input: input)
            + spokenSubmitMissingSuite(input: input)
        if missing.isEmpty { return "rodar medição indisponível" }
        return "rodar medição indisponível, falta \(missing.joined(separator: ", "))"
    }
}

extension ArenaRunSheet {
    func spokenReceiptLabel(_ receipt: AtlasArenaStartReceipt) -> String {
        var parts = ["recibo \(receipt.receiptHash)"]
        parts.append(receipt.isEnqueued ? "na fila, ainda não iniciado" : receipt.status)
        if receipt.workerImplemented == false {
            parts.append("worker de medição ainda não implementado")
        }
        return parts.joined(separator: ", ")
    }
}

extension ArenaRunSheet {
    func spokenCloseLabel() -> String { "fechar folha de medição" }

    func spokenCloseHint() -> String { "volta para a Arena sem enviar" }
}

extension ArenaRunSheet {
    func spokenSubmitEnginesEmpty() -> String {
        "rodar medição indisponível, nenhum motor publicado"
    }
}

extension ArenaRunSheet {
    func spokenSubmitValid() -> String {
        "rodar medição"
    }
}

extension ArenaRunSheet {
    func runSheetA11y<V: View>(_ content: V) -> some View {
        content
            .onAppear { seedDefaultsIfNeeded() }
            .accessibilityIdentifier(A11yID.arenaRunSheet)
            // Contain without fused sheet label so toggles/fields stay focusable.
            .accessibilityElement(children: .contain)
    }
}

extension ArenaRunSheet {
    func receiptCard(_ receipt: AtlasArenaStartReceipt) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            receiptCardCopy(receipt)
        }
        .padding(14)
        .atlasCard()
        .atlasElevation(radius: 8, y: 2, opacity: 0.14)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenReceiptLabel(receipt))
        .accessibilityIdentifier(A11yID.arenaRunReceipt)
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func receiptHashCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        Text("Recibo \(receipt.receiptHash)")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textSecondary)
            .lineLimit(1)
            .truncationMode(.middle)
            .accessibilityHidden(true)
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func receiptStatusCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        Text(receipt.isEnqueued ? "na fila, ainda não iniciado" : receipt.status)
            .font(AtlasFont.serif(15, .semibold))
            .foregroundStyle(AtlasTheme.accent)
            .accessibilityHidden(true)
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func receiptWorkerGapCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        if receipt.workerImplemented == false {
            // false hoje = worker desligado no servidor (ATLAS_ARENA_WORKER_ENABLED).
            Text("Worker de medição desligado no servidor — fila aguardando")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func receiptCardCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        receiptHashCopy(receipt)
        receiptStatusCopy(receipt)
        receiptMultiEngineCopy
        receiptWorkerGapCopy(receipt)
    }

    /// Agregado do start multi-motor (goal 1) — só quando houve 2+ POSTs.
    @ViewBuilder
    var receiptMultiEngineCopy: some View {
        if model.lastStartEnginesCount > 1 {
            Text("\(model.lastStartEnginesCount) motores · \(model.lastStartRunsPlannedTotal) runs na fila")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}

extension ArenaRunSheet {
    func toggleRow(title: String, subtitle: String?, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        } label: {
            toggleLabel(title: title, subtitle: subtitle, isOn: isOn)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(toggleAccessibilityLabel(title: title, subtitle: subtitle, isOn: isOn))
        .accessibilityHint(isOn ? "desmarca esta opção" : "marca esta opção")
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }
}

extension ArenaRunSheet {
    func toggleAccessibilityLabel(title: String, subtitle: String?, isOn: Bool) -> String {
        let state = isOn ? "selecionado" : "não selecionado"
        if let subtitle { return "\(title), \(subtitle), \(state)" }
        return "\(title), \(state)"
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func toggleLabelSymbol(isOn: Bool) -> some View {
        let icon = ArenaPremiumIcon(
            symbol: isOn ? "checkmark.circle" : "circle",
            tone: isOn ? .active : .muted
        )
        if reduceMotion {
            icon
        } else {
            icon.symbolEffect(.bounce, value: isOn)
        }
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func toggleLabelTitleStack(title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(AtlasFont.serif(15, .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            toggleSubtitle(subtitle)
        }
    }
}

extension ArenaRunSheet {
    func toggleLabel(title: String, subtitle: String?, isOn: Bool) -> some View {
        HStack(spacing: 10) {
            toggleLabelSymbol(isOn: isOn)
            toggleLabelTitleStack(title: title, subtitle: subtitle)
            Spacer()
        }
        .frame(minHeight: 48)
        .contentShape(Rectangle())
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func toggleSubtitle(_ subtitle: String?) -> some View {
        if let subtitle {
            Text(subtitle)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var formSections: some View {
        suitesFormSection
        engineFormSection
        formGovernanceSections
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var engineFormEmpty: some View {
        Text("Nenhum motor publicado")
            .font(AtlasFont.serif(14))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityIdentifier(A11yID.arenaRunEnginesEmpty)
            .accessibilityLabel(spokenEmptyEngines())
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var engineFormSection: some View {
        section("Motores") {
            if engines.isEmpty {
                engineFormEmpty
            } else {
                ForEach(engines, id: \.self) { engine in
                    toggleRow(
                        title: ArenaDisplay.engine(engine),
                        subtitle: nil,
                        isOn: selectedEngines.contains(engine)
                    ) {
                        if selectedEngines.contains(engine) {
                            selectedEngines.remove(engine)
                        } else {
                            selectedEngines.insert(engine)
                        }
                    }
                    .accessibilityIdentifier(A11yID.arenaRunEngine(engine))
                }
                if engines.count > 1 {
                    Text("Escolha 2 ou mais para comparar motor contra motor.")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var formGovernanceSections: some View {
        section("Comparação") {
            ForEach(AtlasArenaRunArm.allCases) { arm in
                // Sublinha humana — "baseline"/"with_atlas" era slug de
                // máquina vazando na UI (canon: sem slug cru).
                toggleRow(title: arm.labelPT, subtitle: armSubtitle(arm), isOn: selectedArms.contains(arm)) {
                    if selectedArms.contains(arm), selectedArms.count > 1 { selectedArms.remove(arm) }
                    else { selectedArms.insert(arm) }
                }
                .accessibilityIdentifier(A11yID.arenaRunArm(arm.rawValue))
            }
        }

        governanceFields
    }

    func armSubtitle(_ arm: AtlasArenaRunArm) -> String {
        switch arm {
        case .baseline: "o motor puro, como referência"
        case .withAtlas: "os mesmos casos, com o Atlas"
        }
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var governanceFields: some View {
        section("Governança") {
            // Campos na identidade da casa — .roundedBorder rendia caixas
            // BRANCAS no dark (a maior quebra da folha); rótulo diz o que é.
            fieldLabel("Operador")
            TextField("quem autoriza esta medição", text: $actor)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaRunActor)
                .accessibilityHint(spokenActorHint())
            fieldLabel("Motivo")
            TextField("por que rodar agora (fica no recibo)", text: $reason, axis: .vertical)
                .lineLimit(2...4)
                .modifier(ArenaFieldChrome(minHeight: 88))
                .accessibilityIdentifier(A11yID.arenaRunReason)
                .accessibilityHint(spokenReasonHint())
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .atlasSans(12, .medium)
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityAddTraits(.isHeader)
    }
}

struct ArenaFieldChrome: ViewModifier {
    /// Single-line 48; multi-line reason fields pass 88.
    var minHeight: CGFloat = 48

    func body(content: Content) -> some View {
        content
            .font(AtlasFont.serif(15))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 12).padding(.vertical, 10)
            .frame(
                minHeight: minHeight,
                alignment: minHeight > 48 ? .topLeading : .center
            )
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                    .fill(AtlasTheme.bgRecessed)
                    .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                        .stroke(AtlasTheme.separator, lineWidth: 1)))
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var suitesFormSection: some View {
        section("Suítes") {
            if installedSuites.isEmpty {
                suitesEmptyLabel
            } else {
                suitesToggleRows
            }
        }
    }
}

extension ArenaRunSheet {
    var suitesEmptyLabel: some View {
        Text("Nenhuma suite com adapter instalado")
            .font(AtlasFont.serif(14))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityIdentifier(A11yID.arenaRunSuitesEmpty)
            .accessibilityLabel(spokenEmptySuites())
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var suitesToggleRows: some View {
        ForEach(installedSuites) { suite in
            toggleRow(
                title: suite.suite,
                subtitle: suite.isMeasured ? "\(suite.runsTotal) rodadas" : "Não medido",
                isOn: selectedSuites.contains(suite.suite)
            ) {
                if selectedSuites.contains(suite.suite) { selectedSuites.remove(suite.suite) }
                else { selectedSuites.insert(suite.suite) }
            }
            .accessibilityIdentifier(A11yID.arenaRunSuite(suite.suite))
        }
    }
}

extension ArenaRunSheet {
    /// Catálogo B6 (motores rodáveis, inclusive nunca medidos) ∪ já medidos.
    var engines: [String] {
        let catalog = model.engineCatalog?.engines.map(\.engine) ?? []
        let composite = model.composite?.engines.map(\.engine) ?? []
        let suiteEngines = (model.scoreboard?.suites ?? []).flatMap { $0.engines.map(\.engine) }
        return Array(Set(catalog + composite + suiteEngines)).sorted()
    }
}

extension ArenaRunSheet {
    var installedSuites: [AtlasArenaSuite] {
        (model.scoreboard?.suites ?? []).filter(\.adapterInstalled)
    }
}

extension ArenaRunSheet {
    /// Representativo (validação/A11y) — mesmos campos de todos os POSTs.
    var input: AtlasArenaStartInput {
        payload(engine: selectedEngines.sorted().first ?? "")
    }

    /// Um POST B5 por motor selecionado (goal 1: motor contra motor).
    var inputs: [AtlasArenaStartInput] {
        selectedEngines.sorted().map(payload(engine:))
    }

    private func payload(engine: String) -> AtlasArenaStartInput {
        AtlasArenaStartInput(
            suites: .selected(Array(selectedSuites).sorted()),
            engine: engine,
            arms: AtlasArenaRunArm.allCases.filter { selectedArms.contains($0) },
            operatorActor: actor,
            operatorReason: reason,
            origin: UIDevice.current.userInterfaceIdiom == .pad ? "ipad" : "iphone"
        )
    }
}

extension ArenaRunSheet {
    var submitButtonLabel: some View {
        Text("Rodar medição")
            .font(AtlasFont.serif(16, .semibold))
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .background(Capsule().fill(input.isLocallyValidForSubmission ? AtlasTheme.goldVeil : AtlasTheme.surfaceHi))
            .overlay(Capsule().stroke(input.isLocallyValidForSubmission ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
            .contentShape(Capsule())
    }
}

extension ArenaRunSheet {
    var submitButton: some View {
        Button {
            // Medium: primary run commit (not tab/navigation soft).
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            Task { await model.startRuns(inputs: inputs) }
        } label: {
            submitButtonLabel
        }
        .buttonStyle(PressableScale())
        .foregroundStyle(input.isLocallyValidForSubmission ? AtlasTheme.accent : AtlasTheme.textTertiary)
        .disabled(!input.isLocallyValidForSubmission)
        .accessibilityIdentifier(A11yID.arenaRunSubmit)
        .accessibilityLabel(spokenSubmitLabel(input: input, enginesEmpty: engines.isEmpty))
        .accessibilityHint(spokenSubmitHint(input: input, enginesEmpty: engines.isEmpty))
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(input.isLocallyValidForSubmission ? 9 : 0)
    }
}


// Cycle 044 fuse → ArenaSuiteSheet.swift

// MARK: - Arena suite sheet

struct ArenaSuiteSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let suite: AtlasArenaSuite

    var body: some View {
        suitePresentation
    }
}

// Casos/duração só quando o servidor publica; zero «0» fabricado.

enum ArenaSuiteSheetA11y {
    static func spokenSuiteTitle(_ suite: String) -> String {
        "suite \(suite)"
    }
}

enum ArenaSuiteSheetA11yCaptions {
    static func casesCaption(for engine: AtlasArenaSuiteEngine) -> String? {
        guard let total = engine.casesTotal else { return nil }
        var parts: [String] = []
        if let passed = engine.casesPassed { parts.append("ok \(passed)") }
        if let failed = engine.casesFailed { parts.append("falha \(failed)") }
        parts.append("de \(total) casos")
        return parts.joined(separator: " · ")
    }

    static func durationCaption(for engine: AtlasArenaSuiteEngine) -> String? {
        guard let ms = engine.durationAvgMs else { return nil }
        return "duração média \(ArenaDisplay.duration(ms: ms)) por caso"
    }
}

extension ArenaSuiteSheetA11y {
    static let closeLabel = "fechar detalhes da suite"
    static let closeHint = "volta para a Arena"
    static let sheetHint = "scores, casos e duração só quando o servidor publica"
}

extension ArenaSuiteSheetA11y {
    static func spokenEngine(_ engine: AtlasArenaSuiteEngine) -> String {
        var parts = [engine.engine, "score \(ArenaFormat.score(engine.score))"]
        if engine.regressed { parts.append("regressão detectada") }
        if let cases = ArenaSuiteSheetA11yCaptions.casesCaption(for: engine) { parts.append(cases) }
        if let duration = ArenaSuiteSheetA11yCaptions.durationCaption(for: engine) { parts.append(duration) }
        if !engine.history.isEmpty {
            parts.append("\(engine.history.count) pontos no histórico")
        }
        return parts.joined(separator: ", ")
    }
}

extension ArenaSuiteSheetA11y {
    static func spokenSheet(_ suite: AtlasArenaSuite) -> String {
        let n = suite.engines.count
        if n == 0 {
            return "suite \(suite.suite), nenhum motor neste recorte"
        }
        return "suite \(suite.suite), \(n) motor\(n == 1 ? "" : "es")"
    }
}

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineHistorySparkline(_ engine: AtlasArenaSuiteEngine) -> some View {
        if !engine.history.isEmpty {
            SuiteSparkline(engine: engine).frame(height: 90)
                .accessibilityHidden(true)
        }
    }
}

extension ArenaSuiteSheet {
    func engineCardScore(_ engine: AtlasArenaSuiteEngine) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 3) {
            Text(ArenaFormat.score(engine.score))
                .font(AtlasFont.serif(38))
            if engine.score != nil {
                Text("/10")
                    .font(AtlasFont.mono(9, .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
            .foregroundStyle(engine.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
            .accessibilityHidden(true)
    }
}

extension ArenaSuiteSheet {
    var suitePresentation: some View {
        NavigationStack {
            suiteScrollBody
                .accessibilityIdentifier(A11yID.arenaSuiteSheet)
                // Contain: suite header and engine cards stay separately focusable.
                .accessibilityElement(children: .contain)
        }
    }
}

extension ArenaSuiteSheet {
    @ToolbarContentBuilder
    var suiteToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            AtlasCloseToolbarButton(
                spokenLabel: ArenaSuiteSheetA11y.closeLabel,
                spokenHint: ArenaSuiteSheetA11y.closeHint,
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}

extension ArenaSuiteSheet {
    var suiteBodyTitle: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: suite.hasRegression ? "Regressão detectada" : "Resultado da suíte",
                tone: suite.hasRegression ? .negative : .active
            )
            Text(ArenaDisplay.suite(suite.suite))
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            HStack(spacing: 12) {
                metadata("\(suite.runsTotal) rodadas", symbol: "circle.grid.2x2")
                if let last = ArenaDisplay.relative(suite.lastRunAt) {
                    metadata(last, symbol: "clock")
                }
            }
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenSuiteTitle(suite.suite))
    }

    private func metadata(_ text: String, symbol: String) -> some View {
        HStack(spacing: 5) {
            ArenaPremiumIcon(symbol: symbol, tone: .neutral, role: .compact)
            Text(text)
        }
    }
}

extension ArenaSuiteSheet {
    var suiteScrollBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                suiteBodyTitle
                ForEach(suite.engines) { engine in
                    engineCard(engine)
                    ArenaPremiumHairline()
                }
                Text("Valores ausentes permanecem não medidos. Comparações só aparecem quando os dois braços foram publicados.")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(AtlasTheme.Space.screen)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: suite.engines.count)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle("Suite")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { suiteToolbar }
    }
}

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineCardHeader(_ engine: AtlasArenaSuiteEngine) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(ArenaDisplay.engine(engine.engine))
                    .font(AtlasFont.serif(21))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("Índice da suíte · escala 0–10")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .accessibilityHidden(true)
            Spacer()
            engineCardScore(engine)
        }
    }
}

extension ArenaSuiteSheet {
    func engineCard(_ engine: AtlasArenaSuiteEngine) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            engineCardHeader(engine)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 28) {
                    suiteMetric("Sem Atlas", engine.withoutAtlasScore)
                    suiteMetric("Com Atlas", engine.withAtlasScore, tone: .active)
                    suiteMetric("Diferença", pairedDelta(engine), signed: true, tone: deltaTone(engine))
                }
                VStack(alignment: .leading, spacing: 12) {
                    suiteMetric("Sem Atlas", engine.withoutAtlasScore)
                    suiteMetric("Com Atlas", engine.withAtlasScore, tone: .active)
                    suiteMetric("Diferença", pairedDelta(engine), signed: true, tone: deltaTone(engine))
                }
            }
            ArenaPremiumHairline()
            engineEvidence(engine)
            if !engine.history.isEmpty {
                ArenaPremiumKicker(text: "Histórico")
                engineHistorySparkline(engine)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenEngine(engine))
    }

    private func suiteMetric(
        _ label: String,
        _ value: Double?,
        signed: Bool = false,
        tone: ArenaPremiumTone = .neutral
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(signed ? ArenaFormat.signed(value) : ArenaFormat.score(value))
                .font(AtlasFont.serif(29))
                .foregroundStyle(tone.color)
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(label), \(signed ? ArenaFormat.signed(value) : ArenaFormat.score(value))"
        )
    }

    private func engineEvidence(_ engine: AtlasArenaSuiteEngine) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let cases = ArenaSuiteSheetA11yCaptions.casesCaption(for: engine) {
                evidenceLine(cases, symbol: "checklist")
            }
            if let duration = ArenaSuiteSheetA11yCaptions.durationCaption(for: engine) {
                evidenceLine(duration, symbol: "timer")
            }
            evidenceLine("mesma suíte · braços equivalentes", symbol: "equal.circle")
        }
        .font(AtlasFont.mono(10))
        .foregroundStyle(AtlasTheme.textSecondary)
    }

    private func evidenceLine(_ text: String, symbol: String) -> some View {
        HStack(spacing: 8) {
            ArenaPremiumIcon(symbol: symbol, tone: .neutral, role: .compact)
            Text(text)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }

    private func pairedDelta(_ engine: AtlasArenaSuiteEngine) -> Double? {
        guard let withAtlas = engine.withAtlasScore,
              let withoutAtlas = engine.withoutAtlasScore else { return nil }
        return withAtlas - withoutAtlas
    }

    private func deltaTone(_ engine: AtlasArenaSuiteEngine) -> ArenaPremiumTone {
        guard let delta = pairedDelta(engine), abs(delta) > 0.005 else { return .neutral }
        return delta > 0 ? .positive : .negative
    }
}


// Sparkline da suite — colocalizado com ArenaSuiteSheet.
struct SuiteSparkline: View {
    let engine: AtlasArenaSuiteEngine

    var body: some View {
        Chart(engine.history) { point in
            if let score = point.score {
                LineMark(x: .value("rodada", point.roundAt), y: .value("score", score))
                    .foregroundStyle(point.arm == .withAtlas ? AtlasTheme.accent : AtlasTheme.textSecondary)
                    .interpolationMethod(.linear)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .accessibilityHidden(true)
    }
}


struct ArenaPremiumKicker: View {
    let text: String
    var tone: ArenaPremiumTone = .neutral
    /// Live: ✦ que respira (nunca bola). Demais kickers sem marca.
    var showsLiveMark = false

    var body: some View {
        HStack(spacing: 8) {
            if showsLiveMark {
                Text("✦")
                    .font(AtlasFont.serif(11))
                    .foregroundStyle(tone.color)
                    .modifier(ArenaLiveBreath())
                    .accessibilityHidden(true)
            }
            Text(text)
                .font(AtlasFont.serif(13, .semibold))
                .foregroundStyle(tone.color)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(text)
    }
}

/// Compat: kickers antigos com `showsDot:` viram marca ✦ quando true.
extension ArenaPremiumKicker {
    init(text: String, tone: ArenaPremiumTone = .neutral, showsDot: Bool) {
        self.init(text: text, tone: tone, showsLiveMark: showsDot)
    }
}

private struct ArenaLiveBreath: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var on = false

    func body(content: Content) -> some View {
        content
            .opacity(reduceMotion ? 1 : (on ? 1 : 0.55))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(AtlasMotion.breath(2.4)) { on = true }
            }
    }
}

struct ArenaPremiumHairline: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [AtlasTheme.separator.opacity(0.2), AtlasTheme.separator, AtlasTheme.separator.opacity(0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

struct ArenaPremiumAction: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    var symbol: String? = nil
    var tone: ArenaPremiumTone = .neutral
    var quiet = false
    var disabled = false
    let action: () -> Void

    /// Compat com call sites que passam SF Symbol.
    init(
        title: String,
        symbol: String,
        tone: ArenaPremiumTone = .neutral,
        quiet: Bool = false,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.symbol = symbol
        self.tone = tone
        self.quiet = quiet
        self.disabled = disabled
        self.action = action
    }

    init(
        title: String,
        tone: ArenaPremiumTone = .neutral,
        quiet: Bool = false,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.symbol = nil
        self.tone = tone
        self.quiet = quiet
        self.disabled = disabled
        self.action = action
    }

    var body: some View {
        Button {
            guard !disabled else { return }
            // Quiet = secondary soft; filled = primary medium (map: ação primária).
            if quiet {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
            } else {
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            }
            action()
        } label: {
            Text(title)
                .font(quiet ? AtlasFont.serif(14) : AtlasFont.serif(15, .semibold))
                .frame(maxWidth: .infinity, minHeight: 48)
                .padding(.horizontal, 20)
                .foregroundStyle(disabled ? AtlasTheme.textTertiary : (quiet ? AtlasTheme.textSecondary : AtlasTheme.textPrimary))
                .background(
                    Capsule().fill(
                        quiet || disabled
                            ? Color.clear
                            : AtlasTheme.textPrimary.opacity(0.055)
                    )
                )
                .overlay(
                    Capsule().stroke(
                        quiet
                            ? AtlasTheme.separator.opacity(disabled ? 0.35 : 0.7)
                            : AtlasTheme.textPrimary.opacity(disabled ? 0.05 : 0.12),
                        lineWidth: 1
                    )
                )
                .atlasElevation(radius: 10, y: 3, opacity: quiet || disabled ? 0.06 : 0.16)
                .contentShape(Capsule())
        }
        .buttonStyle(PressableScale())
        .disabled(disabled)
        .accessibilityLabel(title)
        .atlasAccessibilityHint(
            disabled
                ? "Indisponível"
                : (quiet
                    ? "Ação secundária da Arena, \(title)"
                    : "Ação principal da Arena, \(title)")
        )
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(disabled || quiet ? 0 : 9) // primary Arena CTA surfaces early in VO
    }
}

struct ArenaPremiumDisclosureRow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    let detail: String
    let symbol: String
    var tone: ArenaPremiumTone = .neutral
    let action: () -> Void

    var body: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        } label: {
            HStack(spacing: 14) {
                ArenaPremiumIcon(symbol: symbol, tone: tone)
                // Linha de lista fala sans (canon §C — serif é masthead/título);
                // mesma lei aplicada no Código e nos Artifacts hoje.
                Text(title)
                    .atlasSans(16, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer(minLength: 12)
                Text(detail)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(tone.color)
                    .lineLimit(1)
                    .accessibilityHidden(true)
                ArenaPremiumChevron()
            }
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(detail)")
        .accessibilityHint("Abre \(title)")
        .accessibilityAddTraits(.isButton)
    }
}

struct ArenaPremiumProgressRing: View {
    let progress: Double?
    let percentage: Int?

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .trim(from: 0.08, to: 0.92)
                    .stroke(AtlasTheme.textPrimary.opacity(0.06), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                if let progress {
                    Circle()
                        .trim(from: 0.08, to: 0.08 + 0.84 * min(max(progress, 0), 1))
                        .stroke(AtlasTheme.accent, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                }
            }
            .rotationEffect(.degrees(90))
            progressCenter
        }
        .frame(width: 142, height: 142)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var progressCenter: some View {
        if let percentage {
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text("\(percentage)")
                    .font(AtlasFont.serif(42))
                Text("%")
                    .font(AtlasFont.mono(13))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .baselineOffset(4)
            }
            .foregroundStyle(AtlasTheme.textPrimary)
        } else if progress == nil {
            // Indeterminate: ✦ is mark, not a fake 0% ring.
            Text("✦")
                .font(AtlasFont.serif(24))
                .foregroundStyle(AtlasTheme.accent)
                .shadow(color: AtlasTheme.accent.opacity(0.28), radius: 8, y: 1)
        } else {
            // Progress without percentage stays visual-only (parent speaks counts).
            EmptyView()
        }
    }
}

struct ArenaPremiumEmptyGlyph: View {
    let symbol: String
    var tone: ArenaPremiumTone = .neutral

    var body: some View {
        ArenaPremiumIcon(symbol: symbol, tone: tone, role: .hero)
            .background(Circle().fill(AtlasTheme.surface.opacity(0.72)))
            .overlay(Circle().stroke(AtlasTheme.separator, lineWidth: 1))
    }
}


/// Linha operacional com glifo tipográfico (∥ ※ ⌖ ◷) — alfabeto quiet luxury.
/// Sem caixinha SF Symbol de template.
struct ArenaPremiumGlyphRow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let glyph: String
    let title: String
    let detail: String
    var tone: ArenaPremiumTone = .neutral
    var glyphTone: ArenaPremiumTone? = nil
    let action: () -> Void

    var body: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        } label: {
            HStack(spacing: 14) {
                Text(glyph)
                    .font(AtlasFont.serif(14))
                    .foregroundStyle((glyphTone ?? tone).color)
                    .frame(width: 22, alignment: .center)
                    .accessibilityHidden(true)
                Text(title)
                    .atlasSans(16, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer(minLength: 12)
                Text(detail)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(tone.color)
                    .lineLimit(1)
                    .accessibilityHidden(true)
                Text("›")
                    .font(AtlasFont.mono(13))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(detail)")
        .accessibilityHint("Abre \(title)")
        .accessibilityAddTraits(.isButton)
    }
}


enum ArenaPremiumIconRole {
    case compact
    case standard
    case hero

    var pointSize: CGFloat {
        switch self {
        case .compact: 12
        case .standard: 17
        case .hero: 28
        }
    }

    var box: CGFloat {
        switch self {
        case .compact: 16
        case .standard: 24
        case .hero: 68
        }
    }
}

/// The only renderer for symbols inside the Arena surface.
struct ArenaPremiumIcon: View {
    let symbol: String
    var tone: ArenaPremiumTone = .neutral
    var role: ArenaPremiumIconRole = .standard

    var body: some View {
        Image(systemName: symbol)
            .symbolRenderingMode(.monochrome)
            .atlasSans(role.pointSize, .medium)
            .foregroundStyle(tone.color)
            .frame(width: role.box, height: role.box, alignment: .center)
            .accessibilityHidden(true)
    }
}

struct ArenaPremiumChevron: View {
    var body: some View {
        ArenaPremiumIcon(
            symbol: ArenaPremiumIconography.disclosure,
            tone: .muted,
            role: .compact
        )
        .accessibilityHidden(true)
    }
}

enum ArenaPremiumIconography {
    static let action = "play.fill"
    static let add = "plus"
    static let alerts = "exclamationmark.triangle"
    static let blocked = "lock"
    static let comparison = "arrow.right"
    static let coverage = "checkmark.seal"
    static let disclosure = "chevron.right"
    static let execution = "list.bullet.rectangle"
    static let next = "calendar.badge.clock"
    static let plan = "list.bullet.rectangle"
    static let queue = "tray.full"
    static let stop = "stop.fill"

    static func run(_ status: AtlasArenaRunStatus) -> String {
        switch status {
        case .queued: "clock"
        case .running: "play.circle"
        case .stopping: "hourglass"
        case .stopped: "stop.circle"
        case .completed: "checkmark.circle"
        case .failed: "exclamationmark.triangle"
        case .unknown: "questionmark.circle"
        }
    }

    static func planStatus(_ status: AtlasArenaRunStatus?) -> String {
        guard let status else { return "circle" }
        return run(status)
    }

    static func suite(_ suite: String) -> String {
        switch suite {
        case "terminal_bench": "terminal"
        case "bfcl": "wrench.and.screwdriver"
        case "inspect_evals": "arrow.triangle.2.circlepath"
        case "tau2_bench": "function"
        case "live_code_bench", "swe_bench_live":
            "chevron.left.forwardslash.chevron.right"
        default: "diamond"
        }
    }
}


@MainActor
@Observable
final class ArenaModel {
    let client: AtlasClient

    var phase: LoadPhase = .idle
    var composite: AtlasArenaComposite?
    var scoreboard: AtlasArenaScoreboard?
    /// Relatório editorial provider-safe para Resultados, Alertas e detalhes.
    /// Ausente quando o servidor ainda não publicou enterprise/report.json.
    var report: AtlasArenaReport?
    var capabilities: AtlasArenaCapabilities?
    /// Capacidades por motor (goal 3: perfil de habilidades de TODOS os
    /// motores, não só o primeiro). Chave = engine id público.
    var capabilitiesByEngine: [String: AtlasArenaCapabilities] = [:]
    /// Motor escolhido no hero de capacidades (nil = primeiro do índice).
    var capabilitiesEngineSelection: String?
    var liveRuns: AtlasArenaLiveRuns?
    /// Catálogo B6 de motores rodáveis — estreia de motor novo pelo app.
    var engineCatalog: AtlasArenaEngines?
    var lastStartReceipt: AtlasArenaStartReceipt?
    /// Recibo idempotente da última solicitação de parada.
    var lastStopReceipt: AtlasArenaStopReceipt?
    /// Plano local exato do último start pedido pelo operador.
    var activePlan: AtlasArenaMeasurementPlan?
    /// Recibos já confirmados do último start, inclusive quando um lote termina
    /// parcialmente. Um erro posterior nunca apaga o que o servidor enfileirou.
    var lastStartReceipts: [AtlasArenaStartReceipt] = []
    /// Evita POST duplicado por toque repetido enquanto um lote está em voo.
    var isStartingRuns = false
    var isStoppingMeasurement = false
    /// Agregado confirmado do último start multi-motor — soma dos recibos B5.
    var lastStartEnginesCount = 0
    var lastStartRunsPlannedTotal = 0
    var controlError: String?
    /// Tipo de falha de rede (espelha ConversationModel) — casca usa AtlasFailureCopy.
    private(set) var loadFailureKind: AtlasNetworkFailureKind?
    /// 404 / domínio arena ausente — copy própria, não inventa scores.
    private(set) var isDomainUnavailable = false
    private(set) var lastLoadedAt: Date?

    /// Único ponto de escrita do carimbo (peels em outros arquivos usam isto).
    func markLoaded() { lastLoadedAt = Date() }
    var visible = false
    var livePollingTask: Task<Void, Never>?
#if DEBUG
    /// Cenário determinístico exclusivamente para prova visual no simulador.
    var visualScenarioInstalled = false
#endif

    /// Copy canónica quando o servidor ainda não publica medição (spec §E).
    static let domainUnavailableCopy = "medição ainda não publicada pelo servidor"

    init(client: AtlasClient) {
        self.client = client
    }

    /// Motores com perfil de capacidades disponível, na ordem do índice.
    var capabilityEngineOptions: [String] {
        (composite?.engines.map(\.engine) ?? []).filter { capabilitiesByEngine[$0] != nil }
    }

    /// Capacidades do motor escolhido no hero (fallback: primeiro do índice).
    var selectedCapabilities: AtlasArenaCapabilities? {
        if let selection = capabilitiesEngineSelection, let chosen = capabilitiesByEngine[selection] {
            return chosen
        }
        return capabilityEngineOptions.first.flatMap { capabilitiesByEngine[$0] } ?? capabilities
    }

    /// Ponto ÚNICO de carga do hero de capacidades — load() e o refresh da
    /// tela passam por aqui (o refresh keep-snapshot deixava o hero órfão:
    /// launch com rede em corrida → capacidades nunca mais carregavam).
    func loadCapabilities(
        for composite: AtlasArenaComposite,
        preserveCurrentOnTotalFailure: Bool = false
    ) async {
        var byEngine: [String: AtlasArenaCapabilities] = [:]
        var successfulFetches = 0
        let engines = composite.engines.map(\.engine)
        let client = client
        await withTaskGroup(of: (String, AtlasArenaCapabilities?, Bool).self) { group in
            for engine in engines {
                group.addTask {
                    do {
                        return (engine, try await client.getArenaCapabilities(engine: engine), true)
                    } catch {
                        return (engine, nil, false)
                    }
                }
            }
            for await (engine, profile, succeeded) in group {
                if succeeded { successfulFetches += 1 }
                if let profile, !profile.capabilities.isEmpty {
                    byEngine[engine] = profile
                }
            }
        }
        var aggregateCapabilities: AtlasArenaCapabilities?
        if byEngine.isEmpty {
            // Perfil por motor ausente ([]), mas o agregado global pode
            // existir (engine vazio → todos os motores; proveniência DITA).
            if let aggregate = try? await client.getArenaCapabilities(engine: "") {
                successfulFetches += 1
                aggregateCapabilities = aggregate.capabilities.isEmpty ? nil : aggregate
            }
        } else {
            aggregateCapabilities = composite.engines.first.flatMap { byEngine[$0.engine] }
        }
        guard !preserveCurrentOnTotalFailure || successfulFetches > 0 else { return }
        if capabilitiesByEngine != byEngine {
            capabilitiesByEngine = byEngine
        }
        if capabilities != aggregateCapabilities {
            capabilities = aggregateCapabilities
        }
    }

    /// Publica somente mudança semântica do feed. `generated_at` muda a cada
    /// poll, mas não deve invalidar a árvore inteira quando os runs são iguais.
    func publishLiveRuns(_ next: AtlasArenaLiveRuns?) {
        guard let next, liveRuns?.runs != next.runs else { return }
        liveRuns = next
    }

    var preferredEngine: String? {
        composite?.engines.first?.engine
            ?? scoreboard?.suites.lazy.flatMap(\.engines).first?.engine
    }

    /// Fonte única para AGORA: running, fila, falha e estado desconhecido não
    /// são reclassificados pela casca. `nil` significa feed ainda não publicado.
    var livePresentation: AtlasArenaLivePresentation? {
        liveRuns?.presentation
    }

    var regressionException: String? {
        for suite in scoreboard?.suites ?? [] {
            guard let engine = suite.engines.first(where: \.regressed),
                  let delta = engine.delta else { continue }
            // O fato lidera; os nomes vêm depois ("Verboo regrediu" lia como
            // português quebrado quando o braço tem nome próprio).
            return "regrediu \(ArenaFormat.signed(delta)) · \(ArenaDisplay.suite(suite.suite)) · \(ArenaDisplay.engine(engine.engine))"
        }
        return nil
    }

    var snapshotAgeText: String? {
        guard let lastLoadedAt else { return nil }
        let seconds = max(0, Int(Date().timeIntervalSince(lastLoadedAt)))
        switch seconds {
        case ..<60: return "agora"
        case ..<3600: return "há \(seconds / 60)min"
        default: return "há \(seconds / 3600)h"
        }
    }

    func load() async {
#if DEBUG
        // Cenário visual de UITest não pode ser apagado por refresh/rede.
        if visualScenarioInstalled { return }
#endif
        phase = .loading
        controlError = nil
        loadFailureKind = nil
        isDomainUnavailable = false
        do {
            async let compositeRequest = client.getArenaComposite()
            async let scoreboardRequest = client.getArenaScoreboard()
            let (nextComposite, nextScoreboard) = try await (compositeRequest, scoreboardRequest)
            async let reportRequest: AtlasArenaReport? = try? client.getArenaReport()
            async let liveRunsRequest: AtlasArenaLiveRuns? = try? client.getArenaLiveRuns()
            async let engineCatalogRequest: AtlasArenaEngines? = try? client.getArenaEngines()
            // Capacidades ANTES de publicar o composite: @Observable re-renderiza
            // na 1ª atribuição, e o hero não pode nascer dizendo "não medida"
            // enquanto o fetch ainda está em voo (estado atômico, nunca meia-tela).
            await loadCapabilities(for: nextComposite)
            composite = nextComposite
            scoreboard = nextScoreboard
            report = await reportRequest
            publishLiveRuns(await liveRunsRequest)
            engineCatalog = await engineCatalogRequest
            lastLoadedAt = Date()
            phase = .loaded
            updateLivePolling()
        } catch {
            let domainMissing = Self.isDomainUnavailableError(error)
            isDomainUnavailable = domainMissing
            loadFailureKind = domainMissing ? nil : atlasNetworkFailureKind(for: error)
            phase = .failed(Self.publicMessage(error))
        }
    }

    func setVisible(_ isVisible: Bool) {
        visible = isVisible
        updateLivePolling()
    }
}


// Polling de runs vivos — peel de ArenaModel (régua ~120).

extension ArenaModel {
    var shouldPollLiveRuns: Bool {
#if DEBUG
        if visualScenarioInstalled { return false }
#endif
        // Só visibilidade: exigir feed não-vazio criava ovo-e-galinha — um
        // fetch falho (nil) ou fila vazia desligava o polling PARA SEMPRE e
        // a seção AGORA nunca mais voltava (worker medindo, tela muda,
        // 2026-07-18). Custo: 1 GET ~130ms a cada 10s enquanto visível.
        return visible
    }

    func updateLivePolling() {
        guard shouldPollLiveRuns else {
            livePollingTask?.cancel()
            livePollingTask = nil
            return
        }
        guard livePollingTask == nil else { return }
        livePollingTask = Task { @MainActor [weak self] in
            var lastFullRefresh = ContinuousClock.now
            while let self, !Task.isCancelled, self.shouldPollLiveRuns {
                try? await Task.sleep(for: .seconds(10))
                guard !Task.isCancelled, self.shouldPollLiveRuns else { break }
                let runsBefore = self.liveRuns?.runs
                await self.refreshLiveRuns()
                // Medição nova aparece em SEGUNDOS (ordem do operador, 20/07):
                // run vivo transicionou → refresh completo (capacidades +
                // scoreboard + report) NA HORA. Fallback de 30s cobre o que não
                // passa pela fila viva (batteries importam ao fim da suíte).
                let transitioned = runsBefore != self.liveRuns?.runs
                if transitioned || ContinuousClock.now - lastFullRefresh > .seconds(30) {
                    lastFullRefresh = ContinuousClock.now
                    await self.refreshSummaryKeepingSnapshot(quiet: true)
                }
            }
        }
    }

    static func publicMessage(_ error: Error) -> String {
        if isDomainUnavailableError(error) {
            return domainUnavailableCopy
        }
        if let api = error as? AtlasApiError { return api.message }
        return "não foi possível carregar a Arena"
    }

    static func isDomainUnavailableError(_ error: Error) -> Bool {
        (error as? AtlasApiError)?.status == 404
    }
}

#if DEBUG

extension ArenaModel {
    @discardableResult
    func installVisualScenarioIfRequested(
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> Bool {
        guard !visualScenarioInstalled,
              let raw = arguments.value(after: "-atlas.arena.scenario") else {
            return visualScenarioInstalled
        }

        do {
            let snapshot = try AtlasArenaVisualFixture.snapshot(scenario: raw)
            composite = snapshot.composite
            scoreboard = snapshot.scoreboard
            report = snapshot.report
            capabilities = snapshot.capabilities
            capabilitiesByEngine = ["verboo_kimi_k2_7": snapshot.capabilities]
            capabilitiesEngineSelection = "verboo_kimi_k2_7"
            engineCatalog = snapshot.engineCatalog
            liveRuns = snapshot.liveRuns
            activePlan = snapshot.plan
            phase = .loaded
            visualScenarioInstalled = true
            markLoaded()
            return true
        } catch {
            assertionFailure("Arena visual fixture inválida: \(error)")
            return false
        }
    }
}

private extension Array where Element == String {
    func value(after flag: String) -> String? {
        guard let index = firstIndex(of: flag), indices.contains(index + 1) else { return nil }
        return self[index + 1]
    }
}
#endif


// Refresh/start sem polling — peel de ArenaModel (régua ~120).

extension ArenaModel {
    /// `quiet`: refresh disparado pelo POLL — falha transitória não vira banner
    /// (o próximo tick tenta de novo); só o refresh manual mostra erro.
    func refreshSummaryKeepingSnapshot(quiet: Bool = false) async {
        if !quiet { controlError = nil }
        do {
            async let compositeRequest = client.getArenaComposite()
            async let scoreboardRequest = client.getArenaScoreboard()
            let (nextComposite, nextScoreboard) = try await (compositeRequest, scoreboardRequest)
            async let reportRequest: AtlasArenaReport? = try? client.getArenaReport()
            async let liveRunsRequest: AtlasArenaLiveRuns? = try? client.getArenaLiveRuns()
            // Capacidades acompanham o snapshot: refresh sem elas deixava o
            // hero dizendo "nenhuma medida" com medição real viva no servidor.
            await loadCapabilities(for: nextComposite, preserveCurrentOnTotalFailure: true)
            composite = nextComposite
            scoreboard = nextScoreboard
            report = await reportRequest ?? report
            publishLiveRuns(await liveRunsRequest)
            markLoaded()
            if case .idle = phase { phase = .loaded }
            updateLivePolling()
        } catch {
            if !quiet { controlError = Self.publicMessage(error) }
        }
    }

    /// Re-busca capacidades ao abrir a aba Capacidades. O poll de 10s só
    /// atualiza runs VIVAS; sem isto a aba ficava congelada no dado de antes
    /// da última medição (ou de antes de um fix de servidor), mostrando -X
    /// falso onde o servidor já dizia "não medido".
    func refreshCapabilities() async {
        guard let composite else { return }
        await loadCapabilities(for: composite, preserveCurrentOnTotalFailure: true)
    }

    func refreshLiveRuns() async {
        // Ambiente (polling 10s): falha transitória não vira banner — a seção
        // AGORA segue com o último feed conhecido e o próximo tick tenta de novo.
        publishLiveRuns(try? await client.getArenaLiveRuns())
        updateLivePolling()
    }

    /// Um POST B5 por motor (goal 1: motor contra motor numa medição só).
    func startRuns(inputs: [AtlasArenaStartInput]) async {
        guard !isStartingRuns else { return }
        controlError = nil
        guard let plan = AtlasArenaMeasurementPlan(inputs: inputs) else {
            controlError = "Selecione suítes, motores e braços; informe ator e motivo"
            return
        }
        isStartingRuns = true
        defer { isStartingRuns = false }
        activePlan = plan
        lastStartReceipt = nil
        lastStartReceipts = []
        lastStartEnginesCount = 0
        lastStartRunsPlannedTotal = 0
        do {
            for input in inputs {
                let receipt = try await client.startArenaRuns(input: input)
                lastStartReceipt = receipt
                lastStartReceipts.append(receipt)
                lastStartEnginesCount = lastStartReceipts.count
                lastStartRunsPlannedTotal += receipt.runsPlanned
            }
            await refreshLiveRuns()
        } catch {
            if lastStartReceipts.isEmpty {
                controlError = Self.publicMessage(error)
            } else {
                controlError = "\(lastStartReceipts.count) de \(inputs.count) motores enfileirados · o restante não foi confirmado"
                await refreshLiveRuns()
            }
        }
    }

    func stopMeasurement(
        measurementId: String,
        operatorActor: String,
        operatorReason: String
    ) async {
        guard !isStoppingMeasurement else { return }
        let input = AtlasArenaStopInput(
            operatorActor: operatorActor,
            operatorReason: operatorReason
        )
        guard input.isLocallyValidForSubmission else {
            controlError = "Informe operador e motivo para parar a medição"
            return
        }
        isStoppingMeasurement = true
        controlError = nil
        defer { isStoppingMeasurement = false }
        do {
            lastStopReceipt = try await client.stopArenaMeasurement(
                measurementId: measurementId,
                input: input
            )
            await refreshLiveRuns()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}


enum ArenaPremiumTab: String, CaseIterable, Identifiable {
    case now = "Agora"
    case fleet = "Frota"
    case capabilities = "Capac."
    case results = "Motor"

    var id: String { rawValue }

    /// Identificador estável p/ a11y (não depende do rótulo curto da aba).
    var a11yKey: String {
        switch self {
        case .now: "agora"
        case .fleet: "frota"
        case .capabilities: "capacidades"
        case .results: "motor"
        }
    }
}

enum ArenaPremiumDestination: String, Identifiable, Hashable {
    case execution
    case plan
    case queue
    case alerts
    case results

    var id: String { rawValue }
}

enum ArenaPremiumTone {
    case muted
    case neutral
    case active
    case positive
    case negative

    var color: Color {
        switch self {
        case .muted: AtlasTheme.textTertiary
        case .neutral: AtlasTheme.textSecondary
        case .active: AtlasTheme.accent
        case .positive: AtlasTheme.textPrimary
        case .negative: AtlasTheme.alert
        }
    }
}

extension ArenaModel {
    var arenaSelectedEngineID: String? {
        capabilitiesEngineSelection ?? composite?.engines.first?.engine
    }

    var arenaPrimaryEngine: AtlasArenaCompositeEngine? {
        guard let selected = arenaSelectedEngineID else { return composite?.engines.first }
        return composite?.engines.first { $0.engine == selected }
            ?? composite?.engines.first
    }

    var arenaPrimaryRun: AtlasArenaLiveRun? {
        livePresentation?.primaryRun
    }

    var arenaPrimarySuite: AtlasArenaSuite? {
        guard let run = arenaPrimaryRun else { return scoreboard?.suites.first }
        return scoreboard?.suites.first { $0.suite == run.suite }
    }

    var arenaPrimaryMeasurementRuns: [AtlasArenaLiveRun] {
        guard let primary = arenaPrimaryRun else { return [] }
        guard let measurement = primary.measurementIdPublic else { return [primary] }
        return liveRuns?.runs.filter { $0.measurementIdPublic == measurement } ?? [primary]
    }

    var arenaRegressionCount: Int {
        scoreboard?.suites.filter(\.hasRegression).count ?? 0
    }

    var arenaCoverageText: String {
        guard let composite else { return "não medida" }
        return "\(composite.suitesMeasured)/\(composite.suitesTotal) suítes"
    }

    var arenaAlertSuiteCount: Int {
        var suites = Set(scoreboard?.suites.filter(\.hasRegression).map(\.suite) ?? [])
        suites.formUnion(report?.attentionSuites.map(\.suite) ?? [])
        return suites.count
    }

    /// Título humano do motor ao vivo — nunca o literal "motor desconhecido".
    var arenaLiveEngineTitle: String {
        if let id = arenaPrimaryRun?.engine, !id.isEmpty {
            return ArenaDisplay.engine(id)
        }
        if let preferred = preferredEngine, !preferred.isEmpty {
            return ArenaDisplay.engine(preferred)
        }
        if let composite = arenaPrimaryEngine?.engine {
            return ArenaDisplay.engine(composite)
        }
        return "Medição ao vivo"
    }
}


/// Nomes de exibição e datas relativas da Arena — presentation-only.
/// IDs crus continuam nos contratos e nos A11y identifiers; o operador
/// nunca lê snake_case nem ISO 8601 cru.
enum ArenaDisplay {
    private static let engines: [String: String] = [
        "claude_opus_4_8": "Claude Opus 4.8",
        "claude_sonnet_5": "Claude Sonnet 5",
        "codex_gpt_5_5": "Codex · GPT-5.5",
        "codex_cli": "Codex CLI",
        "claude_code": "Claude Code",
        "gemini": "Gemini",
        "minimax_m3": "MiniMax M3",
        "verboo_qwen_3_6_27b": "Qwen 3.6 27B · Verboo",
        "verboo_kimi_k2_7": "Kimi K2.7 · Verboo",
        "glm_5_2": "GLM 5.2",
        "hermes": "Hermes",
    ]

    private static let suites: [String: String] = [
        "terminal_bench": "Terminal Bench",
        "inspect_evals": "Inspect Evals",
        "tau2_bench": "τ²-Bench",
        "bfcl": "BFCL · Funções",
        "senior_swe_bench": "Senior SWE",
        "swe_bench_live": "SWE Live",
        "live_code_bench": "LiveCodeBench",
        "hal_harness": "HAL Harness",
        "aider_polyglot": "Aider Polyglot",
        "swe_marathon": "SWE Marathon",
        "testeval": "TestEval",
    ]

    static func engine(_ id: String) -> String {
        engines[id] ?? humanized(id)
    }

    /// 78778ms → "1min 19s"; 6201ms → "6,2s"; 320ms → "320ms".
    static func duration(ms: Int) -> String {
        if ms < 1000 { return "\(ms)ms" }
        let seconds = Double(ms) / 1000
        if seconds < 60 {
            return String(format: "%.1fs", seconds).replacingOccurrences(of: ".", with: ",")
        }
        let minutes = Int(seconds) / 60
        let rest = Int(seconds) % 60
        return rest == 0 ? "\(minutes)min" : "\(minutes)min \(rest)s"
    }

    /// Origem do run (`iphone|ipad|mac|cli`) → rótulo humano; nil = não dita.
    static func origin(_ id: String?) -> String? {
        switch id {
        case "iphone": return "iPhone"
        case "ipad": return "iPad"
        case "mac": return "Mac"
        case "cli": return "CLI"
        default: return nil
        }
    }

    static func suite(_ id: String) -> String {
        suites[id] ?? humanized(id)
    }

    /// Fallback genérico: snake_case → Palavras Capitalizadas.
    private static func humanized(_ id: String) -> String {
        id.split(separator: "_")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }

    /// "2026-07-16T23:42:29+00:00" → "há 2h"; nil se não parsear (nunca ISO cru).
    static func relative(_ isoString: String?) -> String? {
        guard let date = AtlasTime.date(isoString) else { return nil }
        let seconds = max(0, Int(Date().timeIntervalSince(date)))
        switch seconds {
        case ..<60: return "agora"
        case ..<3600: return "há \(seconds / 60)min"
        case ..<86_400: return "há \(seconds / 3600)h"
        default: return "há \(seconds / 86_400)d"
        }
    }
}

// Formatação de scores/deltas da Arena — peel de ArenaModel (régua ~120).

enum ArenaFormat {
    private static let scoreStyle = FloatingPointFormatStyle<Double>.number
        .locale(Locale(identifier: "pt_BR"))
        .grouping(.never)
        .precision(.fractionLength(0...1))

    private static let multiplierStyle = FloatingPointFormatStyle<Double>.number
        .locale(Locale(identifier: "pt_BR"))
        .grouping(.never)
        .precision(.fractionLength(2))

    static func score(_ value: Double?) -> String {
        guard let value = AtlasArenaPresentationScale.score(value) else {
            return "Não medido"
        }
        return value.formatted(scoreStyle)
    }

    static func signed(_ value: Double?) -> String {
        guard let value = AtlasArenaPresentationScale.delta(value) else {
            return "—"
        }
        if abs(value) < 0.05 {
            return "0"
        }
        return "\(value > 0 ? "+" : "")\(value.formatted(scoreStyle))"
    }

    static func multiplier(_ value: Double?) -> String {
        guard let value else { return "—" }
        return "×\(value.formatted(multiplierStyle))"
    }
}
