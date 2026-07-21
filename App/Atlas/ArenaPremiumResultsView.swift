import SwiftUI
import AtlasCore

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
                Button { onSuite(suite) } label: {
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
                .accessibilityIdentifier(A11yID.arenaPremiumResultSuite(suite.suite))
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
        .accessibilityIdentifier(A11yID.arenaPremiumState("results-empty"))
    }
}
