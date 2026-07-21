import SwiftUI
import AtlasCore

// WAVE-150 density peel

extension ArenaSuiteSheet {
    func engineCardScore(_ engine: AtlasArenaSuiteEngine) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 3) {
            Text(ArenaFormat.score(engine.score))
                .font(AtlasFont.serif(38))
            if engine.score != nil {
                Text("/10")
                    .font(AtlasFont.mono(9, .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
            .foregroundStyle(engine.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
            .accessibilityHidden(true)
    }
}

extension ArenaSuiteSheet {
    /// WAVE-059: suite face + ranked engines.
    var suiteFace: ArenaSuiteFace {
        ArenaSuiteJudgment.face(for: suite)
    }

    var rankedEngines: [AtlasArenaSuiteEngine] {
        ArenaSuiteJudgment.rank(suite.engines)
    }

    var suiteBodyTitle: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: suiteFace.kicker,
                tone: suiteFace.productWord == "regression" ? .negative : .active
            )
            Text(ArenaDisplay.suite(suite.suite))
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
            HStack(spacing: 12) {
                metadata("\(suite.runsTotal) rodadas", symbol: "circle.grid.2x2")
                if let last = ArenaDisplay.relative(suite.lastRunAt) {
                    metadata(last, symbol: "clock")
                }
            }
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(ArenaSuiteJudgment.spokenSuite(suite))
        .accessibilityValue(suiteFace.productWord)
    }

    private func metadata(_ text: String, symbol: String) -> some View {
        HStack(spacing: 5) {
            ArenaPremiumIcon(symbol: symbol, tone: .neutral, role: .compact)
            Text(text)
        }
    }
}

extension ArenaSuiteSheet {
    var suiteScrollBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                suiteBodyTitle
                // WAVE-059: regressed engines first.
                ForEach(rankedEngines) { engine in
                    engineCard(engine)
                    ArenaPremiumHairline()
                }
                Text("Valores ausentes permanecem não medidos. Comparações só aparecem quando os dois braços foram publicados.")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(AtlasTheme.Space.screen)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: suite.engines.count)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle("Suite")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { suiteToolbar }
    }
}

extension ArenaSuiteSheet {
    var suitePresentation: some View {
        NavigationStack {
            suiteScrollBody
                .accessibilityIdentifier(A11yID.arenaSuiteSheet)
        }
    }
}

extension ArenaSuiteSheet {
    @ToolbarContentBuilder
    var suiteToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            AtlasCloseToolbarButton(
                spokenLabel: ArenaSuiteJudgment.closeLabel,
                spokenHint: ArenaSuiteJudgment.closeHint,
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}

struct ArenaSuiteSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let suite: AtlasArenaSuite

    var body: some View {
        suitePresentation
    }
}
