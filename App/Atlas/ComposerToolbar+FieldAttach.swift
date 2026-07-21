import SwiftUI
import AtlasCore

// Attach paperclip — peel de ComposerToolbar+Field.

extension ComposerToolbar {
    var attachButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onAttach()
        } label: {
            Image(systemName: "paperclip")
                .atlasSans(17, .medium)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("adicionar anexo")
        .accessibilityHint("abre foto, arquivo ou colar")
    }
}
