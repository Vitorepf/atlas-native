import SwiftUI
import AtlasCore

// Capsule chrome — peel de ChangeReviewToast.

extension ChangeReviewToast {
    func toastCapsule(_ text: String) -> some View {
        Text(text)
            .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 16).padding(.vertical, 9)
            .frame(minHeight: 44)
            .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
            .padding(.top, 8)
    }
}
