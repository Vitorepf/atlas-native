import SwiftUI
import AtlasCore

// Title block — peel de AtlasCodeProvenanceHeader.

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var headerTitle: some View {
        Group {
            if let message = node.message?.nonEmpty {
                Text(message)
                    .font(AtlasFont.serif(22, .semibold))
            } else {
                Text(String(node.hash.prefix(8)))
                    .font(AtlasFont.mono(22, .semibold))
            }
        }
        .foregroundStyle(AtlasTheme.textPrimary)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityLabel(spokenHeaderTitle())
    }
}
