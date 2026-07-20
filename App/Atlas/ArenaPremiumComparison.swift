import SwiftUI
import AtlasCore

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
            Text(value)
                .font(AtlasFont.serif(28))
                .foregroundStyle(gold ? AtlasTheme.accent : AtlasTheme.textPrimary)
        }
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
