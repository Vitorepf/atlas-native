import SwiftUI
import AtlasCore

// Why failed state — peel de AtlasCodeWhySheet+Loading.

extension AtlasCodeWhySheet {
    var whyFailed: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("biografia indisponível")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            if let message = model.message, !message.isEmpty {
                Text(message)
                    .font(AtlasFont.mono(9.5))
                    .foregroundStyle(AtlasCodePalette.alert)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenFailed())
    }
}
