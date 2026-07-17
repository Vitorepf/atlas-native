import SwiftUI

// Masthead overlay — peel de RootView+Chrome.

extension RootView {
  @ViewBuilder
  var mastheadOverlay: some View {
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
      if session.auditModeEnabled {
        Text("AUDITORIA")
          .font(AtlasFont.mono(8))
          .tracking(1.0)
          .foregroundStyle(AtlasTheme.domOperacional)
          .accessibilityHidden(true)
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(mastheadSpokenLabel(auditModeEnabled: session.auditModeEnabled))
    .accessibilityHint(mastheadSpokenHint())
    .accessibilityIdentifier(A11yID.auditMasthead)
    .accessibilityAddTraits(.isHeader)
    .onLongPressGesture(minimumDuration: 0.55) {
      AtlasMotion.softImpact(reduceMotion: reduceMotion)
      session.auditModeEnabled.toggle()
    }
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
  }
}
