import SwiftUI
import AtlasCore

// MARK: - Arena suite sheet
// Engine sheet → ArenaEngineSheet.swift · SuiteSparkline vive em ArenaSuitesSection.

struct ArenaSuiteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
                    Button("Fechar") {
                        AtlasMotion.softImpact(reduceMotion: reduceMotion)
                        dismiss()
                    }
                        .accessibilityLabel(ArenaSuiteSheetA11y.closeLabel)
                        .accessibilityHint(ArenaSuiteSheetA11y.closeHint)
                }
            }
        }
        .accessibilityIdentifier(A11yID.arenaSuiteSheet)
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenSheet(suite))
        .accessibilityHint(ArenaSuiteSheetA11y.sheetHint)
    }

    private func engineCard(_ engine: AtlasArenaSuiteEngine) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(engine.engine)
                    .font(.system(.headline))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                Spacer()
                Text(ArenaFormat.score(engine.score))
                    .font(AtlasFont.mono(16))
                    .foregroundStyle(engine.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
            }
            if let cases = ArenaSuiteSheetA11y.casesCaption(for: engine) {
                Text(cases)
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityHidden(true)
            }
            if let duration = ArenaSuiteSheetA11y.durationCaption(for: engine) {
                Text(duration)
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            if !engine.history.isEmpty {
                SuiteSparkline(engine: engine).frame(height: 90)
                    .accessibilityHidden(true)
            }
        }
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenEngine(engine))
    }
}
