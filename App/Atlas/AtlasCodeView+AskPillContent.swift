import SwiftUI
import AtlasCore

// Conteúdo visual da pílula — glass canônico + fio de ouro (paridade home/mockup).

extension AtlasCodeView {
    @ViewBuilder
    var askPillContent: some View {
        askPillLeading
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .atlasGlassCapsule()
            .overlay(
                Capsule()
                    .strokeBorder(AtlasTheme.goldBorder.opacity(0.45), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.22), radius: 10, y: 4)
            .contentShape(Capsule())
    }
}
