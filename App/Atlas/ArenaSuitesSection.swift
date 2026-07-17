import SwiftUI
import Charts
import AtlasCore

struct ArenaSuitesSection: View {
    let scoreboard: AtlasArenaScoreboard?
    let onSuiteTap: (AtlasArenaSuite) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("SUITES")
                    .font(.system(.caption, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityIdentifier(A11yID.arenaSuitesSection)
                Spacer()
                Text("\(scoreboard?.suites.count ?? 0)")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }

            if let suites = scoreboard?.suites, !suites.isEmpty {
                ForEach(suites) { suite in
                    Button { onSuiteTap(suite) } label: {
                        ArenaSuiteRow(suite: suite)
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(suite.suite), \(suite.arenaSubtitleText)")
                    .accessibilityIdentifier("arena-suite-\(suite.suite)")
                }
            } else {
                Text("não medido")
                    .font(AtlasFont.mono(13))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.vertical, 8)
            }
        }
        .padding(16)
        .atlasCard()
    }
}

private struct ArenaSuiteRow: View {
    let suite: AtlasArenaSuite

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(suite.suite.uppercased())
                        .font(AtlasFont.mono(12))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .lineLimit(1)
                    if !suite.adapterInstalled {
                        Text("sem adapter")
                            .font(AtlasFont.mono(9))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    if suite.hasRegression {
                        Circle().fill(AtlasTheme.alert).frame(width: 7, height: 7)
                    }
                }
                Text(subtitle)
                    .font(.system(.caption))
                    .foregroundStyle(suite.isMeasured ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            if let engine = suite.engines.first, !engine.history.isEmpty {
                SuiteSparkline(engine: engine).frame(width: 64, height: 30)
            } else {
                Text("não medido")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private var subtitle: String {
        suite.arenaSubtitleText
    }
}

private extension AtlasArenaSuite {
    var arenaSubtitleText: String {
        guard isMeasured else { return "não medido" }
        let rounds = runsTotal == 1 ? "1 rodada" : "\(runsTotal) rodadas"
        if let lastRunAt { return "\(rounds) · \(lastRunAt)" }
        return rounds
    }
}

private struct SuiteSparkline: View {
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
