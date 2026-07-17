import SwiftUI
import Charts
import AtlasCore

// MARK: - Arena suite / engine sheets
// Extraídos de ArenaSuitesSection sem mudança de comportamento.
// SuiteSparkline vive em ArenaSuitesSection.swift (módulo interno).

struct ArenaSuiteSheet: View {
    @Environment(\.dismiss) private var dismiss
    let suite: AtlasArenaSuite

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(suite.suite.uppercased())
                        .font(AtlasFont.mono(18))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    ForEach(suite.engines) { engine in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(engine.engine)
                                    .font(.system(.headline))
                                    .foregroundStyle(AtlasTheme.textPrimary)
                                Spacer()
                                Text(ArenaFormat.score(engine.score))
                                    .font(AtlasFont.mono(16))
                                    .foregroundStyle(engine.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
                            }
                            Text("casos ok \(engine.casesPassed ?? 0) · falha \(engine.casesFailed ?? 0) / \(engine.casesTotal ?? 0)")
                                .font(AtlasFont.mono(12))
                                .foregroundStyle(AtlasTheme.textSecondary)
                            Text("duração média \(engine.durationAvgMs.map { "\($0)ms" } ?? "não medido")")
                                .font(AtlasFont.mono(12))
                                .foregroundStyle(AtlasTheme.textTertiary)
                            if !engine.history.isEmpty {
                                SuiteSparkline(engine: engine).frame(height: 90)
                            }
                        }
                        .padding(14)
                        .atlasCard()
                    }
                }
                .padding(AtlasTheme.Space.screen)
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Suite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
        .accessibilityIdentifier(A11yID.arenaSuiteSheet)
    }
}

struct ArenaEngineSheet: View {
    @Environment(\.dismiss) private var dismiss
    let engine: AtlasArenaCompositeEngine
    let capabilities: AtlasArenaCapabilities?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(engine.engine)
                        .font(.system(.title2, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    engineSummary
                    ArenaCapabilitiesSection(capabilities: capabilities)
                }
                .padding(AtlasTheme.Space.screen)
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Motor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
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
            }
        }
        .padding(16)
        .atlasCard()
    }
}
