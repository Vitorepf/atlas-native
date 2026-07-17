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
                        ArenaEngineIndexRow(engine: engine)
                    }
                    .buttonStyle(.plain)
                } else {
                    ArenaEngineIndexRow(engine: engine)
                }
            }
            if let engine = composite.engines.first, !engine.history.isEmpty {
                ArenaCompositeChart(engine: engine, reduceMotion: reduceMotion)
                    .frame(height: 170)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .atlasCard()
    }

    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text("O ÍNDICE")
                    .font(.system(.caption, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(AtlasTheme.textTertiary)
                Text("cobertura \(composite.suitesMeasured)/\(composite.suitesTotal) · parcial")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            Spacer()
            Text("\(composite.weightsPublic.count) pesos")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }
}

private struct ArenaEngineIndexRow: View {
    let engine: AtlasArenaCompositeEngine

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
                Text(ArenaFormat.signed(engine.delta))
                    .font(AtlasFont.mono(12))
                    .foregroundStyle((engine.delta ?? 0) < 0 ? AtlasTheme.alert : AtlasTheme.accent)
                    .monospacedDigit()
            }
            HStack(spacing: 10) {
                metric("c/Atlas", ArenaFormat.score(engine.withAtlasComposite), color: AtlasTheme.accent)
                metric("sem", ArenaFormat.score(engine.withoutAtlasComposite), color: AtlasTheme.textSecondary)
                metric("N×M", ArenaFormat.multiplier(engine.atlasMultiplier), color: AtlasTheme.textPrimary)
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

    private var accessibilityText: String {
        "\(engine.engine), composto \(ArenaFormat.score(engine.composite)), variação \(ArenaFormat.signed(engine.delta)), com Atlas \(ArenaFormat.score(engine.withAtlasComposite)), multiplicador \(ArenaFormat.multiplier(engine.atlasMultiplier))"
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
