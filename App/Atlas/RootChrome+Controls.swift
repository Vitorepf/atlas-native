import SwiftUI
import AtlasCore

// BreathingGlyph — peel de RootChrome.
// CircleButton → RootChrome+CircleButton.swift

/// O ✦ respirando — a marca viva do Atlas nos estados de espera.
struct BreathingGlyph: View {
    let reduceMotion: Bool
    @State var on = false
    var body: some View {
        Text("✦")
            .font(AtlasFont.serif(30)).foregroundStyle(AtlasTheme.accent)
            .shadow(color: AtlasTheme.accent.opacity(0.30), radius: 4, y: 1)
            .scaleEffect(on ? 1.08 : 1).opacity(on ? 0.8 : 1)
            .onAppear {
                if !reduceMotion {
                    withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { on = true }
                }
            }
            .accessibilityHidden(true)
    }
}
