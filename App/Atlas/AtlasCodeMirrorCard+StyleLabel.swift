import AtlasCore
import SwiftUI

// Mirror label row — peel de AtlasCodeMirrorCard+Style.

extension AtlasCodeMirrorCard {
    func label(_ text: String, color: Color, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            Text(text)
                .atlasSans(12.5)
                .accessibilityHidden(true)
        }
        .foregroundStyle(color)
        .accessibilityHidden(true)
    }
}
