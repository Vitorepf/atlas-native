import SwiftUI
import AtlasCore

struct ArenaPremiumShell: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var model: ArenaModel
    @Binding var selectedTab: ArenaPremiumTab
    @Binding var destination: ArenaPremiumDestination?
    @Binding var selectedSuite: AtlasArenaSuite?
    @Binding var selectedCapability: AtlasArenaCapability?
    @Binding var showingRunSheet: Bool
    @Binding var stoppingRun: AtlasArenaLiveRun?

    var body: some View {
        VStack(spacing: 0) {
            ArenaPremiumTabBar(selection: $selectedTab)
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 8)
                .padding(.bottom, 10)
                .background(AtlasTheme.bg)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 26) {
                    selectedContent
                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 8)))
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 16)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
        .toolbar { addToolbarItem }
        .navigationDestination(item: $destination) { target in
            ArenaPremiumDestinationView(
                target: target,
                model: model,
                onStop: { stoppingRun = $0 },
                onSuite: { selectedSuite = $0 }
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
            case .results:
                ArenaPremiumResultsView(
                    model: model,
                    reduceMotion: reduceMotion,
                    onSuite: { selectedSuite = $0 }
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
            // Item de toolbar puro: no iOS 26 a barra JÁ dá o vidro — caixa
            // custom + atlasGlassCircle rendia vidro sobre vidro (anel duplo).
            Button { showingRunSheet = true } label: {
                Image(systemName: ArenaPremiumIconography.add)
                    .atlasSans(17, .medium)
                    .foregroundStyle(AtlasTheme.accent)
            }
            .accessibilityLabel("Nova medição")
            .accessibilityHint("Escolhe motores, suítes e braços")
            .accessibilityIdentifier(A11yID.arenaPremiumAdd)
        }
    }
}
