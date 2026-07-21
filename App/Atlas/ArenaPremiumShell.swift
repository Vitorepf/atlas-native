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
                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 8)))
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 12)
                .padding(.bottom, 108)
            }
            .scrollIndicators(.hidden)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
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
            Button { showingRunSheet = true } label: {
                Image(systemName: ArenaPremiumIconography.add)
                    .atlasSans(17, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
            }
            .accessibilityLabel("Nova medição")
            .accessibilityHint("Escolhe motores, suítes e braços")
            .accessibilityIdentifier(A11yID.arenaPremiumAdd)
        }
    }
}
