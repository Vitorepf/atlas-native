import SwiftUI
import Charts
import AtlasCore

// MARK: - Arena engine sheet (peel de ArenaSuiteSheet)

struct ArenaEngineSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let engine: AtlasArenaCompositeEngine
    let capabilities: AtlasArenaCapabilities?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(engine.engine)
                        .font(.system(.title2, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel(ArenaEngineSheetA11y.spokenEngineTitle(engine.engine))
                    engineSummary
                    ArenaCapabilitiesSection(capabilities: capabilities, reduceMotion: reduceMotion)
                }
                .padding(AtlasTheme.Space.screen)
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Motor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                        .accessibilityLabel(ArenaEngineSheetA11y.closeLabel)
                        .accessibilityHint(ArenaEngineSheetA11y.closeHint)
                }
            }
        }
        .accessibilityIdentifier(A11yID.arenaEngineSheet)
    }

    private var engineSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("composto")
                    .font(.system(.caption, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(AtlasTheme.textTertiary)
                Spacer()
                Text(ArenaFormat.score(engine.composite))
                    .font(AtlasFont.mono(20))
                    .foregroundStyle(engine.composite == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
            }
            HStack(spacing: 10) {
                Text("c/Atlas \(ArenaFormat.score(engine.withAtlasComposite))")
                    .foregroundStyle(AtlasTheme.accent)
                Text("sem \(ArenaFormat.score(engine.withoutAtlasComposite))")
                    .foregroundStyle(AtlasTheme.textSecondary)
                Text(ArenaFormat.multiplier(engine.atlasMultiplier))
                    .foregroundStyle(AtlasTheme.textPrimary)
            }
            .font(AtlasFont.mono(11))
            if !engine.history.isEmpty {
                Chart(engine.history) { point in
                    if let composite = point.composite {
                        LineMark(x: .value("rodada", point.roundAt), y: .value("composto", composite))
                            .foregroundStyle(AtlasTheme.accent)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis { AxisMarks(position: .leading) }
                .frame(height: 150)
                .accessibilityHidden(true)
            }
        }
        .padding(16)
        .atlasCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ArenaEngineSheetA11y.spokenSummary(engine))
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: engine.history.count)
    }
}
