import SwiftUI
import AtlasCore

// Input pill — peel de RootView+Chrome (régua ≤100).

extension RootView {
    @ViewBuilder
    var inputBar: some View {
        Button { path.append(Route.new) } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus").font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 30, height: 30).background(Circle().fill(AtlasTheme.surfaceHi))
                    .accessibilityHidden(true)
                Text("Escreva ao Atlas").font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Spacer()
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Capsule().fill(AtlasTheme.surface).overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)))
        }
        .buttonStyle(.plain)
        .keyboardShortcut("n", modifiers: .command)
        .accessibilityLabel(inputPillSpokenLabel())
        .accessibilityHint(newConversationSpokenHint())
        .accessibilityIdentifier(A11yID.homeInputPill)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}
