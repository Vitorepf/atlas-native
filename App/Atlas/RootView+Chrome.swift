import SwiftUI
import AtlasCore

// Masthead + input pill — peel de RootView (régua anti-inchaço).

extension RootView {
  @ViewBuilder
  var topBar: some View {
    HStack(spacing: 12) {
      Circle()
        .fill(AtlasTheme.surface)
        .frame(width: 44, height: 44)
        .overlay(Image(systemName: "person.fill").font(.system(size: 18)).foregroundStyle(AtlasTheme.textSecondary))
        .overlay(Circle().stroke(AtlasTheme.separator, lineWidth: 1))
      CircleButton(icon: "point.3.connected.trianglepath.dotted",
                   badge: codeHub?.exception != nil) { path.append(Route.code) }
        .accessibilityLabel(codeHub?.exception == nil
                            ? "Atlas Código"
                            : "Atlas Código, \(codeHub?.exception?.count ?? 0) exceções")
        .accessibilityIdentifier(A11yID.topbarCode)
      Spacer()
      CircleButton(icon: "magnifyingglass") { path.append(Route.search) }
        .keyboardShortcut("k", modifiers: .command)
      CircleButton(icon: "plus") { path.append(Route.new) }
        .keyboardShortcut("n", modifiers: .command)
    }
    .overlay {
      VStack(spacing: 5) {
        HStack(spacing: 4) {
          Text("Atlas")
            .font(AtlasFont.serif(24, .semibold))
          Text("✦")
            .font(AtlasFont.serif(15, .semibold))
            .foregroundStyle(session.auditModeEnabled ? AtlasTheme.domOperacional : AtlasTheme.accent)
        }
        .foregroundStyle(AtlasTheme.textPrimary)
        Rectangle()
          .fill(AtlasTheme.accent.opacity(0.6))
          .frame(width: 30, height: 1.5)
        if session.auditModeEnabled {
          Text("AUDITORIA")
            .font(AtlasFont.mono(8))
            .tracking(1.0)
            .foregroundStyle(AtlasTheme.domOperacional)
        }
      }
      .accessibilityElement(children: .combine)
      .accessibilityLabel("Atlas")
      .accessibilityIdentifier(A11yID.auditMasthead)
      .accessibilityAddTraits(.isHeader)
      .onLongPressGesture(minimumDuration: 0.55) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        session.auditModeEnabled.toggle()
      }
      .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }
  }

  @ViewBuilder
  var inputBar: some View {
    Button { path.append(Route.new) } label: {
      HStack(spacing: 10) {
        Image(systemName: "plus").font(.system(size: 17, weight: .medium))
          .foregroundStyle(AtlasTheme.textSecondary)
          .frame(width: 30, height: 30).background(Circle().fill(AtlasTheme.surfaceHi))
        Text("Escreva ao Atlas").font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
        Spacer()
      }
      .padding(.horizontal, 12).padding(.vertical, 8)
      .background(Capsule().fill(AtlasTheme.surface).overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)))
    }
    .buttonStyle(.plain)
    .keyboardShortcut("n", modifiers: .command)
    .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
    .background(
      LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea()
    )
  }
}
