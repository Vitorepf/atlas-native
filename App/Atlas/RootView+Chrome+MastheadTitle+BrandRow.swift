import SwiftUI

// Brand row — peel de RootView+Chrome+MastheadTitle.

extension RootView {
  var mastheadBrandRow: some View {
    HStack(spacing: 4) {
      Text("Atlas")
        .font(AtlasFont.serif(24, .semibold))
        .accessibilityHidden(true)
      Text("✦")
        .font(AtlasFont.serif(15, .semibold))
        .foregroundStyle(session.auditModeEnabled ? AtlasTheme.domOperacional : AtlasTheme.accent)
        .accessibilityHidden(true)
    }
    .foregroundStyle(AtlasTheme.textPrimary)
  }
}
