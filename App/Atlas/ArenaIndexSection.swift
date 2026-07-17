import SwiftUI
import Charts
import AtlasCore

struct ArenaIndexSection: View {
    let composite: AtlasArenaComposite
    let reduceMotion: Bool
    var onEngineTap: ((AtlasArenaCompositeEngine) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader
            ForEach(composite.engines) { engine in
                if let onEngineTap {
                    Button { onEngineTap(engine) } label: {
                        ArenaEngineIndexRow(engine: engine, reduceMotion: reduceMotion)
                    }
                    .buttonStyle(.plain)
                } else {
                    ArenaEngineIndexRow(engine: engine, reduceMotion: reduceMotion)
                }
            }
            if let engine = chartEngine {
                ArenaCompositeChart(engine: engine, reduceMotion: reduceMotion)
                    .frame(height: 170)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .atlasCard()
    }

    private var chartEngine: AtlasArenaCompositeEngine? {
        composite.engines.first { engine in
            engine.history.contains { point in
                point.composite != nil || point.withAtlas != nil || point.withoutAtlas != nil
            }
        }
    }

    private var coverageCaption: String {
        let base = "cobertura \(composite.suitesMeasured)/\(composite.suitesTotal)"
        guard composite.suitesMeasured < composite.suitesTotal else { return base }
        return "\(base) · parcial"
    }

    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text("O ÍNDICE")
                    .font(.system(.caption, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(AtlasTheme.textTertiary)
                Text(coverageCaption)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            Spacer()
            if !composite.weightsPublic.isEmpty {
                Text("\(composite.weightsPublic.count) pesos")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityLabel("\(composite.weightsPublic.count) pesos públicos")
            }
        }
    }
}

private struct ArenaEngineIndexRow: View {
    let engine: AtlasArenaCompositeEngine
    let reduceMotion: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(engine.engine)
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(ArenaFormat.score(engine.composite))
                    .font(AtlasFont.mono(18))
                    .foregroundStyle(engine.composite == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                Text(ArenaFormat.signed(engine.delta))
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(deltaColor(engine.delta))
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
            }
            HStack(spacing: 10) {
                metric("c/Atlas", ArenaFormat.score(engine.withAtlasComposite), color: metricColor(engine.withAtlasComposite))
                metric("sem", ArenaFormat.score(engine.withoutAtlasComposite), color: metricColor(engine.withoutAtlasComposite, fallback: AtlasTheme.textSecondary))
                if engine.atlasMultiplier != nil {
                    metric("N×M", ArenaFormat.multiplier(engine.atlasMultiplier), color: AtlasTheme.textPrimary)
                }
            }
            if engine.isPartialCoverage {
                Text("cobertura parcial \(Int((engine.coverage * 100).rounded()))%")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private func metric(_ label: String, _ value: String, color: Color) -> some View {
        Text("\(label) \(value)")
            .font(AtlasFont.mono(11))
            .foregroundStyle(color)
            .monospacedDigit()
    }

    private func metricColor(_ value: Double?, fallback: Color = AtlasTheme.accent) -> Color {
        value == nil ? AtlasTheme.textTertiary : fallback
    }

    private func deltaColor(_ delta: Double?) -> Color {
        guard let delta else { return AtlasTheme.textTertiary }
        return delta < 0 ? AtlasTheme.alert : AtlasTheme.accent
    }

    private var accessibilityText: String {
        var parts = ["\(engine.engine), composto \(ArenaFormat.score(engine.composite))"]
        if let delta = engine.delta {
            parts.append("variação \(ArenaFormat.signed(delta))")
        }
        parts.append("com Atlas \(ArenaFormat.score(engine.withAtlasComposite))")
        if let multiplier = engine.atlasMultiplier {
            parts.append("multiplicador \(ArenaFormat.multiplier(multiplier))")
        }
        if engine.isPartialCoverage {
            parts.append("cobertura parcial \(Int((engine.coverage * 100).rounded())) por cento")
        }
        return parts.joined(separator: ", ")
    }
}

private struct ArenaCompositeChart: View {
    let engine: AtlasArenaCompositeEngine
    let reduceMotion: Bool

    var body: some View {
        Chart {
            ForEach(engine.history) { point in
                if let composite = point.composite {
                    LineMark(x: .value("rodada", point.roundAt), y: .value("composto", composite))
                        .foregroundStyle(AtlasTheme.accent)
                        .interpolationMethod(reduceMotion ? .linear : .catmullRom)
                }
                if let withAtlas = point.withAtlas {
                    LineMark(x: .value("rodada", point.roundAt), y: .value("com Atlas", withAtlas), series: .value("série", "com Atlas"))
                        .foregroundStyle(AtlasTheme.accent.opacity(0.65))
                        .interpolationMethod(.linear)
                }
                if let withoutAtlas = point.withoutAtlas {
                    LineMark(x: .value("rodada", point.roundAt), y: .value("sem Atlas", withoutAtlas), series: .value("série", "sem Atlas"))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .interpolationMethod(.linear)
                }
            }
        }
        .chartLegend(.visible)
        .chartXAxis(.hidden)
        .chartYAxis { AxisMarks(position: .leading) }
        .accessibilityLabel("histórico do índice \(engine.engine)")
    }
}
