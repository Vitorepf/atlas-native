import SwiftUI
import AtlasCore

struct AtlasArenaView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(AtlasSession.self) var session
    @Bindable var model: ArenaModel
    @State var selectedSuite: AtlasArenaSuite?
    @State var selectedEngine: AtlasArenaCompositeEngine?
    @State var showingRunSheet = false

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
}
