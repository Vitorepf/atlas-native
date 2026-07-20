import SwiftUI
import AtlasCore

// Surface do composer — peel de ConversationComposer+Actions.
// Foco = forma (cápsula → cartão), não borda dourada gritante.

extension ConversationComposer {
    @ViewBuilder var composerSurface: some View {
        if expanded || liveBubble != nil {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(AtlasTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(AtlasTheme.separator.opacity(0.95), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.16), radius: 12, y: 4)
        } else {
            Capsule(style: .continuous)
                .fill(AtlasTheme.surface)
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(AtlasTheme.separator, lineWidth: 1)
                )
        }
    }
}
