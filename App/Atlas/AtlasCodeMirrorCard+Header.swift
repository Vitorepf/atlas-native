import AtlasCore
import SwiftUI

// Mirror header — peel de AtlasCodeMirrorCard.

extension AtlasCodeMirrorCard {
    var mirrorHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("Espelho")
                .font(AtlasFont.serif(18, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Spacer()
            if let host = response.mirror?.host {
                Text(host)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }
}
