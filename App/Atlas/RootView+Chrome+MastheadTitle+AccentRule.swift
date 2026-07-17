import SwiftUI

// Accent rule — peel de RootView+Chrome+MastheadTitle.

extension RootView {
  var mastheadAccentRule: some View {
    Rectangle()
      .fill(AtlasTheme.accent.opacity(0.6))
      .frame(width: 30, height: 1.5)
      .accessibilityHidden(true)
  }
}
