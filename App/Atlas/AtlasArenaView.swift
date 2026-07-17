import SwiftUI
import AtlasCore

struct AtlasArenaView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var model: ArenaModel
    @State private var selectedSuite: AtlasArenaSuite?
    @State private var selectedEngine: AtlasArenaCompositeEngine?

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
        .task {
            if case .idle = model.phase {
                await model.load()
            }
        }
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
        case .failed(let message) where model.composite == nil:
            stateCard(message)
        default:
            if let composite = model.composite {
                ArenaIndexSection(
                    composite: composite,
                    reduceMotion: reduceMotion,
                    onEngineTap: { selectedEngine = $0 }
                )
                    .accessibilityIdentifier(A11yID.arenaIndexSection)
                ArenaCapabilitiesSection(capabilities: model.capabilities)
                    .accessibilityIdentifier(A11yID.arenaCapabilitiesSection)
                ArenaSuitesSection(
                    scoreboard: model.scoreboard,
                    onSuiteTap: { selectedSuite = $0 }
                )
                .accessibilityIdentifier(A11yID.arenaSuitesSection)
            } else {
                stateCard("medição ainda não publicada pelo servidor")
            }
        }
    }

    private var loadingCard: some View {
        HStack(spacing: 12) {
            BreathingDiamond(size: 9, reduceMotion: reduceMotion)
            Text("carregando índice medido…")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .atlasCard()
    }

    private func stateCard(_ message: String) -> some View {
        Text(message)
            .font(.system(.subheadline))
            .foregroundStyle(AtlasTheme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .atlasCard()
    }

    private func exceptionBanner(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AtlasTheme.alert)
            Text(text)
                .font(.system(.callout, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.alert.opacity(0.10)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.alert.opacity(0.35), lineWidth: 1))
    }
}
