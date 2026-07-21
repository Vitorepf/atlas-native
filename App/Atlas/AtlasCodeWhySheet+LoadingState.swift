import SwiftUI
import AtlasCore

// Why loading state — peel de AtlasCodeWhySheet+Loading.

extension AtlasCodeWhySheet {
    var whyLoading: some View {
        HStack(spacing: 10) {
            BreathingDiamond(size: 10, reduceMotion: reduceMotion)
                .accessibilityHidden(true)
            Text("lendo a história do arquivo…")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(.top, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLoading())
    }
}
