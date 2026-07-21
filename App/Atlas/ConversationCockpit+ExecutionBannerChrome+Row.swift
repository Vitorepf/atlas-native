import SwiftUI

// Banner row — peel de ConversationCockpit+ExecutionBannerChrome.

extension ExecutionBanner {
    var bannerContentRow: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .atlasSans(11, .semibold)
                .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                .accessibilityHidden(true)
            Text(text)
                .font(AtlasFont.mono(10))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundStyle(tint)
    }
}
