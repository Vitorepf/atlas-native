import SwiftUI

// Masthead title stack — peel de RootView+Chrome+Masthead.

extension RootView {
  var mastheadTitleStack: some View {
    VStack(spacing: 5) {
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
      Rectangle()
        .fill(AtlasTheme.accent.opacity(0.6))
        .frame(width: 30, height: 1.5)
        .accessibilityHidden(true)
      mastheadAuditBadge
    }
  }
}
