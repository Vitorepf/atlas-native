import SwiftUI

// Banner frame — peel de ConversationCockpit+ExecutionBannerChrome.

extension ExecutionBanner {
    func bannerChromeFrame<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(tint.opacity(0.10)))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(tint.opacity(0.35), lineWidth: 1))
    }
}
