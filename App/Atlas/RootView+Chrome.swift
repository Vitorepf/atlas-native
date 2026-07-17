import SwiftUI
import AtlasCore

// Masthead — peel de RootView (régua anti-inchaço).
// Overlay → RootView+Chrome+Masthead.swift · Input pill → RootView+InputBar.swift
// Trailing → RootView+Chrome+Trailing.swift

extension RootView {
  @ViewBuilder
  var topBar: some View {
    HStack(spacing: 12) {
      Circle()
        .fill(AtlasTheme.surface)
        .frame(width: 44, height: 44)
        .overlay(Image(systemName: "person.fill").font(.system(size: 18)).foregroundStyle(AtlasTheme.textSecondary))
        .overlay(Circle().stroke(AtlasTheme.separator, lineWidth: 1))
        .accessibilityHidden(true)
      CircleButton(icon: "point.3.connected.trianglepath.dotted",
                   badge: codeHub?.exception != nil) { path.append(Route.code) }
        .accessibilityLabel(RootHomeSections.codeTopBarLabel(hub: codeHub))
        .accessibilityHint("abre radar de repositórios")
        .accessibilityIdentifier(A11yID.topbarCode)
      Spacer()
      topBarTrailing
    }
    .overlay { mastheadOverlay }
  }
}
