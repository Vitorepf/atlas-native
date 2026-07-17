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
                    ForEach(suite.engines) { engine in
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
                            Text("casos ok \(engine.casesPassed ?? 0) · falha \(engine.casesFailed ?? 0) / \(engine.casesTotal ?? 0)")
                                .font(AtlasFont.mono(12))
                                .foregroundStyle(AtlasTheme.textSecondary)
                            Text("duração média \(engine.durationAvgMs.map { "\($0)ms" } ?? "não medido")")
                                .font(AtlasFont.mono(12))
                                .foregroundStyle(AtlasTheme.textTertiary)
                            if !engine.history.isEmpty {
                                SuiteSparkline(engine: engine).frame(height: 90)
                            }
                        }
                        .padding(14)
                        .atlasCard()
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
                }
            }
        }
        .accessibilityIdentifier(A11yID.arenaSuiteSheet)
    }
}
