import SwiftUI
import PhotosUI
import AtlasCore

// Surface do composer — peel de ConversationComposer+Actions.

extension ConversationComposer {
    @ViewBuilder var composerSurface: some View {
        if expanded || liveBubble != nil {
            // Com execução viva o card cresce em cartão (capsule de 2 linhas
            // deformaria); a borda dourada continua reservada ao foco.
            RoundedRectangle(cornerRadius: 26, style: .continuous).fill(AtlasTheme.surface)
                .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(expanded ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
                .shadow(color: .black.opacity(0.18), radius: 12, y: 4)
        } else {
            Capsule(style: .continuous).fill(AtlasTheme.surface)
                .overlay(Capsule(style: .continuous).stroke(AtlasTheme.separator, lineWidth: 1))
        }
    }
}
