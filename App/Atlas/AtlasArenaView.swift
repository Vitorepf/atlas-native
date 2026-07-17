import SwiftUI
import AtlasCore

struct AtlasArenaView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(AtlasSession.self) var session
    @Bindable var model: ArenaModel
    @State private var selectedSuite: AtlasArenaSuite?
    @State private var selectedEngine: AtlasArenaCompositeEngine?
    @State private var showingRunSheet = false

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    if let exception = model.regressionException {
                        exceptionBanner(exception)
                    }
                    content
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.vertical, 18)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Arena")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier(A11yID.arenaScreen)
        .sheet(item: $selectedSuite) { suite in
            ArenaSuiteSheet(suite: suite)
        }
        .sheet(item: $selectedEngine) { engine in
            ArenaEngineSheet(engine: engine, capabilities: model.capabilities)
        }
        .sheet(isPresented: $showingRunSheet) {
            ArenaRunSheet(model: model)
        }
        .task {
            if case .idle = model.phase {
                await model.load()
            }
        }
        .onAppear { model.setVisible(true) }
        .onDisappear { model.setVisible(false) }
        .refreshable { await model.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("ARENA")
                .font(.system(.caption, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(AtlasTheme.textTertiary)
            Text("Medição dos motores")
                .font(AtlasFont.serif(28, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            if let age = model.snapshotAgeText {
                Text("snapshot \(age)")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Arena, medição dos motores")
    }

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .idle where model.composite == nil,
             .loading where model.composite == nil:
            loadingCard
        case .failed where model.composite == nil:
            // Sem composite: nunca inventar scores. 404 → domínio ausente;
            // resto → AtlasFailureCopy (mesma voz da home/workspace).
            if model.isDomainUnavailable {
                stateCard(ArenaModel.domainUnavailableCopy)
            } else {
                networkFailureCard
            }
        default:
            if let composite = model.composite {
                ArenaNowSection(liveRuns: model.liveRuns, reduceMotion: reduceMotion)
                ArenaIndexSection(
                    composite: composite,
                    reduceMotion: reduceMotion,
                    onEngineTap: { selectedEngine = $0 }
                )
                    .accessibilityIdentifier(A11yID.arenaIndexSection)
                ArenaCapabilitiesSection(capabilities: model.capabilities)
                    .accessibilityIdentifier(A11yID.arenaCapabilitiesSection)
                if let scoreboard = model.scoreboard, !scoreboard.suites.isEmpty {
                    ArenaSuitesSection(
                        scoreboard: scoreboard,
                        onSuiteTap: { selectedSuite = $0 }
                    )
                }
                Button {
                    showingRunSheet = true
                } label: {
                    Label("Rodar medição", systemImage: "play.fill")
                        .font(.system(.body, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(AtlasTheme.goldVeil))
                        .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityIdentifier(A11yID.arenaRunButton)
            } else {
                // Domínio ainda sem índice — copy canónica, zero scores inventados.
                stateCard(ArenaModel.domainUnavailableCopy)
            }
        }
    }
}
