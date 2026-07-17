import SwiftUI
import AtlasCore

// Week heal chrome — peel de AtlasCodeGraphChrome+WeekHealLabel.

extension AtlasCodeView {
    func weekHealChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.vertical, 11)
            .padding(.horizontal, 13)
            .background(AtlasCodePalette.healed.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(AtlasCodePalette.healed.opacity(0.3), lineWidth: 1)
            )
    }
}
