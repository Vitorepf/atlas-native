import SwiftUI
import AtlasCore

// MARK: - Arena suite sheet
// Engine sheet → ArenaEngineSheet.swift · SuiteSparkline vive em ArenaSuitesSection.

struct ArenaSuiteSheet: View {
    @Environment(\.dismiss) private var dismiss
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
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Suite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                        .accessibilityLabel(ArenaSuiteSheetA11y.closeLabel)
                        .accessibilityHint(ArenaSuiteSheetA11y.closeHint)
                }
            }
        }
        .accessibilityIdentifier(A11yID.arenaSuiteSheet)
    }

    private func engineCard(_ engine: AtlasArenaSuiteEngine) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(engine.engine)
                    .font(.system(.headline))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer()
                Text(ArenaFormat.score(engine.score))
                    .font(AtlasFont.mono(16))
                    .foregroundStyle(engine.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
            }
            if let cases = ArenaSuiteSheetA11y.casesCaption(for: engine) {
                Text(cases)
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            if let duration = ArenaSuiteSheetA11y.durationCaption(for: engine) {
                Text(duration)
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            if !engine.history.isEmpty {
                SuiteSparkline(engine: engine).frame(height: 90)
            }
        }
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenEngine(engine))
    }
}
