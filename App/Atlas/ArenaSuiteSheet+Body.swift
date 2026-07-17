import SwiftUI
import AtlasCore

// Suite sheet scroll body — peel de ArenaSuiteSheet.

extension ArenaSuiteSheet {
    var suiteScrollBody: some View {
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
        .toolbar { suiteToolbar }
    }
}
