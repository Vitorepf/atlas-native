import SwiftUI
import AtlasCore
import Charts

struct ArenaPremiumResultsView: View {
    @Bindable var model: ArenaModel
    let reduceMotion: Bool
    let onSuite: (AtlasArenaSuite) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            if let engine = model.arenaPrimaryEngine {
                resultHeader(engine)
                resultMetrics(engine)
                if !engine.history.isEmpty {
                    ArenaPremiumKicker(text: "Índice por rodada")
                    ArenaCompositeChart(engine: engine, reduceMotion: reduceMotion)
                        .frame(height: 190)
                }
                suiteList
            } else {
                empty
            }
        }
    }

    private var measuredEngineOptions: [String] {
        model.composite?.engines.map(\.engine) ?? []
    }

    private func resultHeader(_ engine: AtlasArenaCompositeEngine) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: model.report?.claimAllowed == true ? "Última medição concluída" : "Medição parcial"
            )
            .accessibilityIdentifier(A11yID.arenaPremiumResults)
            ArenaPremiumEngineTitle(
                engineID: engine.engine,
                options: measuredEngineOptions,
                onSelect: { model.capabilitiesEngineSelection = $0 }
            )
            if let narrative = model.report?.narrative {
                Text(narrative)
                    .font(.system(.callout))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func resultMetrics(_ engine: AtlasArenaCompositeEngine) -> some View {
        let atlasDelta = pairedDelta(engine)
        return VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Índice").font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(ArenaFormat.score(engine.composite))
                            .font(AtlasFont.serif(62))
                        Text("/10")
                            .font(AtlasFont.mono(13, .medium))
                            .foregroundStyle(AtlasTheme.textSecondary)
                    }
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(ArenaFormat.score(engine.composite)) de 10")
                }
                Spacer()
                if let atlasDelta {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(ArenaFormat.signed(atlasDelta))
                            .font(AtlasFont.serifItalic(18))
                            .foregroundStyle(atlasDelta >= 0 ? AtlasTheme.accent : AtlasTheme.alert)
                        Text("vs. sem Atlas")
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textSecondary)
                    }
                }
            }
            ArenaPremiumHairline()
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 28) {
                    smallMetric("Sem Atlas", ArenaFormat.score(engine.withoutAtlasComposite))
                    smallMetric("Com Atlas", ArenaFormat.score(engine.withAtlasComposite), tone: .active)
                    smallMetric("Multiplicador", ArenaFormat.multiplier(engine.atlasMultiplier), tone: .active)
                }
                VStack(alignment: .leading, spacing: 12) {
                    smallMetric("Sem Atlas", ArenaFormat.score(engine.withoutAtlasComposite))
                    smallMetric("Com Atlas", ArenaFormat.score(engine.withAtlasComposite), tone: .active)
                    smallMetric("Multiplicador", ArenaFormat.multiplier(engine.atlasMultiplier), tone: .active)
                }
            }
            Text("cobertura \(model.arenaCoverageText) · \(model.report?.claimAllowed == true ? "resultado final" : "resultado parcial")")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private var suiteList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ArenaPremiumKicker(text: "Por suíte")
                .padding(.bottom, 8)
            ForEach(model.scoreboard?.suites ?? []) { suite in
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onSuite(suite)
                } label: {
                    HStack(spacing: 13) {
                        ArenaPremiumIcon(
                            symbol: ArenaPremiumIconography.suite(suite.suite),
                            tone: suite.hasRegression ? .negative : .neutral
                        )
                        Text(ArenaDisplay.suite(suite.suite))
                            .font(AtlasFont.serif(17))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Spacer()
                        suiteMetric(suite)
                        ArenaPremiumChevron()
                    }
                    .frame(minHeight: 54)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(ArenaDisplay.suite(suite.suite))
                .accessibilityHint(
                    suite.hasRegression
                        ? "abre a suíte com regressão"
                        : "abre o detalhe da suíte"
                )
                .accessibilityIdentifier(A11yID.arenaPremiumResultSuite(suite.suite))
                .accessibilityAddTraits(.isButton)
                ArenaPremiumHairline()
            }
            Text("Resultados ausentes aparecem como não medidos, nunca como zero.")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.top, 16)
        }
    }

    @ViewBuilder
    private func suiteMetric(_ suite: AtlasArenaSuite) -> some View {
        if let engine = suite.engines.first(where: { $0.engine == model.arenaSelectedEngineID })
            ?? suite.engines.first {
            HStack(spacing: 6) {
                Text(ArenaFormat.score(engine.score))
                    .foregroundStyle(AtlasTheme.textPrimary)
                if let delta = engine.delta {
                    Text(ArenaFormat.signed(delta))
                        .foregroundStyle(delta < 0 ? AtlasTheme.alert : (delta > 0 ? AtlasTheme.textPrimary : AtlasTheme.textSecondary))
                }
            }
            .font(AtlasFont.mono(11, .medium))
        } else {
            Text("não medido")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }

    private func smallMetric(
        _ label: String,
        _ value: String,
        tone: ArenaPremiumTone = .neutral
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textSecondary)
            Text(value).font(AtlasFont.mono(18, .medium)).foregroundStyle(tone.color)
        }
    }

    private func pairedDelta(_ engine: AtlasArenaCompositeEngine) -> Double? {
        guard let withAtlas = engine.withAtlasComposite,
              let withoutAtlas = engine.withoutAtlasComposite else { return nil }
        return withAtlas - withoutAtlas
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 18) {
            ArenaPremiumEmptyGlyph(symbol: "chart.xyaxis.line")
            Text("Nenhum resultado medido")
                .font(AtlasFont.serif(31))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("O primeiro resultado aparecerá quando uma suíte concluir.")
                .font(.system(.body))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Nenhum resultado medido. O primeiro resultado aparecerá quando uma suíte concluir."
        )
        .accessibilityIdentifier(A11yID.arenaPremiumState("results-empty"))
    }
}



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

// Cycle 046 fused ArenaComposite+UI.swift

extension AtlasArenaCompositeEngine {
    /// Cobertura incompleta — casca só rotula «parcial» com prova do contrato.
    var isPartialCoverage: Bool {
        coverage < 1.0
    }
}


struct ArenaPremiumComparison: View {
    @Bindable var model: ArenaModel
    let provisional: Bool

    /// Par publicado: suíte da corrida → qualquer suíte do motor → composto.
    private var pair: PublishedPair? {
        if let suiteEngine = suiteEnginePair,
           let without = suiteEngine.withoutAtlasScore,
           let withAtlas = suiteEngine.withAtlasScore {
            return PublishedPair(
                without: without,
                withAtlas: withAtlas,
                source: .suite
            )
        }
        if let engine = model.arenaPrimaryEngine,
           let without = engine.withoutAtlasComposite,
           let withAtlas = engine.withAtlasComposite {
            return PublishedPair(without: without, withAtlas: withAtlas, source: .composite)
        }
        return nil
    }

    private var suiteEnginePair: AtlasArenaSuiteEngine? {
        let engineID = resolvedEngineID
        let suites = model.scoreboard?.suites ?? []
        if let run = model.arenaPrimaryRun {
            if let match = suites.first(where: { $0.suite == run.suite })?
                .engines.first(where: { engineMatches($0.engine, engineID) }),
               match.withoutAtlasScore != nil,
               match.withAtlasScore != nil {
                return match
            }
        }
        // Último par publicado do mesmo motor (suíte da corrida pode ainda
        // não ter scoreboard — a medição ao vivo não apaga o histórico).
        return suites
            .flatMap(\.engines)
            .first {
                engineMatches($0.engine, engineID)
                    && $0.withoutAtlasScore != nil
                    && $0.withAtlasScore != nil
            }
    }

    private var resolvedEngineID: String? {
        if let engine = model.arenaPrimaryRun?.engine, !engine.isEmpty { return engine }
        return model.preferredEngine ?? model.arenaPrimaryEngine?.engine
    }

    var body: some View {
        Group {
            if let pair {
                VStack(alignment: .leading, spacing: 12) {
                    ArenaPremiumHairline()
                    ArenaPremiumKicker(text: kickerTitle(for: pair))
                    values(pair)
                }
            }
            // Sem par publicado: some a seção inteira — kicker órfão era mentira
            // visual (título sem 6,0 → 7,6).
        }
    }

    private func kickerTitle(for pair: PublishedPair) -> String {
        switch pair.source {
        case .suite:
            return provisional ? "Último par · escala 0–10" : "Comparação final · escala 0–10"
        case .composite:
            return provisional ? "Índice do motor · escala 0–10" : "Comparação final · escala 0–10"
        }
    }

    private func values(_ pair: PublishedPair) -> some View {
        let delta = pair.withAtlas - pair.without
        return HStack(alignment: .lastTextBaseline, spacing: 14) {
            metric(ArenaFormat.score(pair.without), "Sem Atlas", gold: false)
            Text("→")
                .font(AtlasFont.serif(15))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.bottom, 2)
                .accessibilityHidden(true)
            metric(ArenaFormat.score(pair.withAtlas), "Com Atlas", gold: true)
            Spacer(minLength: 4)
            Text(ArenaFormat.signed(delta))
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(
                    abs(delta) < 0.005
                        ? AtlasTheme.textSecondary
                        : (delta > 0 ? AtlasTheme.accent : AtlasTheme.alert)
                )
                .padding(.bottom, 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Sem Atlas \(ArenaFormat.score(pair.without)), com Atlas \(ArenaFormat.score(pair.withAtlas)), diferença \(ArenaFormat.signed(delta))"
        )
    }

    private func metric(_ value: String, _ label: String, gold: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label.uppercased())
                .font(AtlasFont.mono(9))
                .tracking(1.2)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(value)
                .font(AtlasFont.serif(28))
                .foregroundStyle(gold ? AtlasTheme.accent : AtlasTheme.textPrimary)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value)")
    }

    private func engineMatches(_ candidate: String, _ expected: String?) -> Bool {
        guard let expected, !expected.isEmpty else { return true }
        return candidate == expected
    }

    private struct PublishedPair {
        enum Source { case suite, composite }
        let without: Double
        let withAtlas: Double
        let source: Source
    }
}
