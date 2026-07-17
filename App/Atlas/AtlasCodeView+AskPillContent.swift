import SwiftUI
import AtlasCore

// Conteúdo visual da pílula — peel de AtlasCodeView+AskPill.
// Leading → AtlasCodeView+AskPillLeading.swift

extension AtlasCodeView {
    @ViewBuilder
    var askPillContent: some View {
        askPillLeading
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(AtlasTheme.separator, lineWidth: 0.5))
            .contentShape(Capsule())
    }
}
