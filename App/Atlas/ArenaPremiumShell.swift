import SwiftUI
import AtlasCore

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
