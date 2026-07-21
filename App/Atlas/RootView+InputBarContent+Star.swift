import SwiftUI

// Estrela viva da pílula — peel de RootView+InputBarContent.
// Mesma gramática de BreathingGlyph, escala de composer.

extension RootView {
    struct HomeComposerStar: View {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @State private var on = false

        var body: some View {
            ZStack {
                Circle()
                    .fill(AtlasTheme.goldVeil)
                    .blur(radius: 6)
                    .scaleEffect(on ? 1.18 : 0.92)
                    .opacity(on ? 0.95 : 0.4)
                Text("✦")
                    .font(AtlasFont.serif(16))
                    .foregroundStyle(AtlasTheme.accent)
                    .shadow(color: AtlasTheme.accent.opacity(0.35), radius: 5, y: 0)
            }
            .frame(width: 30, height: 30)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(AtlasMotion.breath(2.8)) { on = true }
            }
            .accessibilityHidden(true)
        }
    }
}
