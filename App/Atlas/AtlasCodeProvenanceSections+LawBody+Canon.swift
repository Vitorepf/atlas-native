import SwiftUI
import AtlasCore

// Law canon text — peel de AtlasCodeProvenanceSections+LawBody.

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func lawCanonText(_ ruleCanon: String) -> some View {
        Text(ruleCanon)
            .font(AtlasFont.mono(8.5))
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.85))
            .lineLimit(1)
            .truncationMode(.head)
            .accessibilityHidden(true)
    }
}
