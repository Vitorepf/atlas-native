import SwiftUI
import AtlasCore

// Truncation note — peel de AtlasCodeWhySheet+Header.

extension AtlasCodeWhySheet {
    @ViewBuilder
    var headerTruncation: some View {
        if let why = model.why, why.truncated {
            Text("mostrando \(why.commits.count) de \(why.commitsTotal) · história truncada")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
