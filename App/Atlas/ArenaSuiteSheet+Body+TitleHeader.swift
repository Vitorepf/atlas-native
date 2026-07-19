import SwiftUI
import AtlasCore

// Suite title header — peel de ArenaSuiteSheet+Body.

extension ArenaSuiteSheet {
    var suiteBodyTitle: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: suite.hasRegression ? "Regressão detectada" : "Resultado da suíte",
                tone: suite.hasRegression ? .negative : .active
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
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenSuiteTitle(suite.suite))
    }

    private func metadata(_ text: String, symbol: String) -> some View {
        HStack(spacing: 5) {
            ArenaPremiumIcon(symbol: symbol, tone: .neutral, role: .compact)
            Text(text)
        }
    }
}
