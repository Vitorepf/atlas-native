import SwiftUI
import AtlasCore

// MARK: - Arena suite sheet
// Engine card → ArenaSuiteSheet+EngineCard.swift

struct ArenaSuiteSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let suite: AtlasArenaSuite

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(suite.suite.uppercased())
                        .font(AtlasFont.mono(18))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel(ArenaSuiteSheetA11y.spokenSuiteTitle(suite.suite))
                    ForEach(suite.engines) { engine in
                        engineCard(engine)
                    }
                }
                .padding(AtlasTheme.Space.screen)
                .animation(reduceMotion ? nil : AtlasMotion.editorial, value: suite.engines.count)
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Suite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AtlasCloseToolbarButton(
                        spokenLabel: ArenaSuiteSheetA11y.closeLabel,
                        spokenHint: ArenaSuiteSheetA11y.closeHint,
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
            }
        }
        .accessibilityIdentifier(A11yID.arenaSuiteSheet)
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenSheet(suite))
        .accessibilityHint(ArenaSuiteSheetA11y.sheetHint)
    }
}
