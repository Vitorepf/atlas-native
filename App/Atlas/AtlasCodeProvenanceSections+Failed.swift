import SwiftUI
import AtlasCore

// Provenance failed state — peel de AtlasCodeProvenanceSections+Content.

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailed(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("proveniência indisponível")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            if let detail = message.nonEmpty {
                Text(detail)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasCodePalette.alert)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenFailed(message))
    }
}
