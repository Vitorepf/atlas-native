import SwiftUI
import AtlasCore

// Masthead — peel de RootView (régua anti-inchaço).
// Input pill → RootView+InputBar.swift

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
      CircleButton(icon: "magnifyingglass") { path.append(Route.search) }
        .keyboardShortcut("k", modifiers: .command)
        .accessibilityLabel(searchSpokenLabel())
        .accessibilityHint("abre busca nas conversas carregadas")
        .accessibilityIdentifier(A11yID.topbarSearch)
      CircleButton(icon: "plus") { path.append(Route.new) }
        .keyboardShortcut("n", modifiers: .command)
        .accessibilityLabel(newConversationSpokenLabel())
        .accessibilityHint(newConversationSpokenHint())
        .accessibilityIdentifier(A11yID.topbarNew)
    }
    .overlay {
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
}
