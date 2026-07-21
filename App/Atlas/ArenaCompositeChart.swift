import AtlasCore
import Charts
import SwiftUI


/// Gráfico de histórico do índice (composto / com Atlas / sem Atlas).
struct ArenaCompositeChart: View {
    let engine: AtlasArenaCompositeEngine
    let reduceMotion: Bool

    private var interpolation: InterpolationMethod { reduceMotion ? .linear : .catmullRom }

    /// Domínio ajustado ao dado: eixo fixo 0–1 espremia as linhas.
    private var fittedYDomain: ClosedRange<Double> {
        let values = engine.history.flatMap { [$0.composite, $0.withAtlas, $0.withoutAtlas].compactMap { $0 } }
        guard let lo = values.min(), let hi = values.max(), hi > lo else { return 0 ... 1 }
        let pad = max(0.04, (hi - lo) * 0.3)
        return max(0, lo - pad) ... min(1, hi + pad)
    }

    var body: some View {
        Chart {
            ForEach(engine.history) { point in
                if let composite = point.composite {
                    LineMark(
                        x: .value("rodada", point.roundAt),
                        y: .value("composto", composite)
                    )
                    .foregroundStyle(AtlasTheme.accent)
                    .interpolationMethod(interpolation)
                }
                if let withAtlas = point.withAtlas {
                    LineMark(
                        x: .value("rodada", point.roundAt),
                        y: .value("com Atlas", withAtlas),
                        series: .value("série", "com Atlas")
                    )
                    .foregroundStyle(AtlasTheme.accent.opacity(0.65))
                    .interpolationMethod(interpolation)
                }
                if let withoutAtlas = point.withoutAtlas {
                    LineMark(
                        x: .value("rodada", point.roundAt),
                        y: .value("sem Atlas", withoutAtlas),
                        series: .value("série", "sem Atlas")
                    )
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .interpolationMethod(interpolation)
                }
            }
        }
        .chartLegend(.visible)
        .chartXAxis(.hidden)
        .chartYScale(domain: fittedYDomain)
        .chartYAxis { AxisMarks(position: .leading) }
        .accessibilityHidden(true)
    }
}

/// Spoken do gráfico composto — só quando o histórico publica valores.
enum ArenaCompositeChartA11y {
    static func spokenChart(_ engine: AtlasArenaCompositeEngine) -> String {
        let plotted = engine.history.filter {
            $0.composite != nil || $0.withAtlas != nil || $0.withoutAtlas != nil
        }
        guard !plotted.isEmpty else { return "" }
        var parts = ["gráfico de histórico do motor \(engine.engine)"]
        let rounds = plotted.count
        parts.append(rounds == 1 ? "1 rodada" : "\(rounds) rodadas")
        if plotted.contains(where: { $0.composite != nil }) { parts.append("linha composta") }
        if plotted.contains(where: { $0.withAtlas != nil }) { parts.append("linha com Atlas") }
        if plotted.contains(where: { $0.withoutAtlas != nil }) { parts.append("linha sem Atlas") }
        return parts.joined(separator: ", ")
    }
}

// Cycle 046 fused ArenaComposite+UI.swift

extension AtlasArenaCompositeEngine {
    /// Cobertura incompleta — casca só rotula «parcial» com prova do contrato.
    var isPartialCoverage: Bool {
        coverage < 1.0
    }
}
