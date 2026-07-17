import SwiftUI
import AtlasCore

// Trailing measured/sparkline — peel de ArenaSuiteRow.

extension ArenaSuiteRow {
    @ViewBuilder
    var suiteTrailing: some View {
        if let engine = suite.engines.first,
           ArenaSuitesSectionA11y.hasSparkline(for: suite) {
            SuiteSparkline(engine: engine).frame(width: 64, height: 30)
        } else if suite.isMeasured {
            Text("medido")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        } else {
            Text("não medido")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }

    var subtitle: String {
        suite.arenaSubtitleText
    }
}
