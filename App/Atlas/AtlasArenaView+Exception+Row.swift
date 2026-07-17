import SwiftUI
import AtlasCore

// Exception row — peel de AtlasArenaView+Exception.

extension AtlasArenaView {
    func exceptionBannerRow(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AtlasTheme.alert)
                .accessibilityHidden(true)
            Text(text)
                .font(.system(.callout, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}
