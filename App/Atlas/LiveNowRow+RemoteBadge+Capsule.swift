import SwiftUI
import AtlasCore

// Remote badge capsule — peel de LiveNowRow+RemoteBadge.

extension LiveNowRow {
    var remoteBadgeCapsule: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 8, weight: .semibold))
                .accessibilityHidden(true)
            Text("remota")
                .font(AtlasFont.mono(9))
                .tracking(0.4)
                .accessibilityHidden(true)
        }
        .foregroundStyle(AtlasTheme.accent)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Capsule().fill(AtlasTheme.goldVeil))
        .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
    }
}
