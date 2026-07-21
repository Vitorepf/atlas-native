import SwiftUI
import AtlasCore
import Foundation

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
                    .frame(width: 44, height: 44)
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
            .font(.system(.callout))
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
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
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
                        .atlasSans(13, .medium)
                        .foregroundStyle(selection == tab ? AtlasTheme.textPrimary : AtlasTheme.textTertiary)
                        .frame(maxWidth: .infinity, minHeight: 48) // HIG 44+; match primary CTA breath
                        .background {
                            if selection == tab {
                                Capsule()
                                    .fill(AtlasTheme.surfaceHi)
                                    .shadow(color: .black.opacity(0.22), radius: 5, y: 1)
                                    .matchedGeometryEffect(id: "arena-tab", in: selectionNamespace)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(tabAccessibilityLabel(tab)))
                .accessibilityAddTraits(selection == tab ? [.isButton, .isSelected] : .isButton)
                .accessibilityIdentifier(A11yID.arenaPremiumTab(tab.a11yKey))
                .accessibilityHint(selection == tab ? Text("selecionado") : Text("troca aba da Arena"))
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
            case .execution: return "pergunte sobre esta execução"
            case .queue: return "pergunte sobre a fila"
            case .alerts: return "pergunte sobre estes alertas"
            case .plan: return "pergunte sobre este plano"
            case .results: return "pergunte sobre este motor"
            }
        }
        switch tab {
        case .now: return "pergunte sobre esta medição"
        case .fleet: return "pergunte sobre a frota medida"
        case .capabilities: return "pergunte sobre estas capacidades"
        case .results: return "pergunte sobre este motor"
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
                let mult = engine.atlasMultiplier.map(ArenaFormat.multiplier) ?? "não medido"
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
                        .font(.system(.body))
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
                    .font(.system(.callout, weight: .semibold))
                    .foregroundStyle(value.accepted ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
                Text(value.stopsAfterCurrentCase ? "parada após o caso atual" : value.status.rawValue)
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
                .font(.system(.body, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 50)
                .foregroundStyle(valid && !isConfirmed ? AtlasTheme.alert : AtlasTheme.textTertiary)
                .background(Capsule().fill(AtlasTheme.alert.opacity(valid && !isConfirmed ? 0.08 : 0.03)))
                .overlay(Capsule().stroke(AtlasTheme.alert.opacity(valid && !isConfirmed ? 0.5 : 0.15), lineWidth: 1))
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
