import SwiftUI

// Brand row — peel de RootView+Chrome+MastheadTitle.

extension RootView {
  var mastheadBrandRow: some View {
    HStack(spacing: 7) {
      Text("Atlas")
        .font(AtlasFont.serif(23, .semibold))
        .accessibilityHidden(true)
      Text("✦")
        .font(AtlasFont.serif(12, .semibold))
        .foregroundStyle(session.auditModeEnabled ? AtlasTheme.domOperacional : AtlasTheme.accent)
        .shadow(
          color: (session.auditModeEnabled ? AtlasTheme.domOperacional : AtlasTheme.accent)
            .opacity(0.35),
          radius: 5,
          y: 0
        )
        .accessibilityHidden(true)
    }
    .foregroundStyle(AtlasTheme.textPrimary)
  }
}
