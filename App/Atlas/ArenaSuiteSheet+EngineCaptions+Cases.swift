import SwiftUI
import AtlasCore

// Cases caption — peel de ArenaSuiteSheet+EngineCaptions.

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineCasesCaption(_ engine: AtlasArenaSuiteEngine) -> some View {
        if let cases = ArenaSuiteSheetA11yCaptions.casesCaption(for: engine) {
            Text(cases)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
    }
}
