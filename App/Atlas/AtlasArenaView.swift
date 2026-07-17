import SwiftUI

struct AtlasArenaView: View {
    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 14) {
                Text("Arena")
                    .font(AtlasFont.serif(28, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("medição dos motores")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Arena, medição dos motores")
        }
        .navigationTitle("Arena")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier(A11yID.arenaScreen)
    }
}
