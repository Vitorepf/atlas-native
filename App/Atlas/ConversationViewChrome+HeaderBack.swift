import SwiftUI
import AtlasCore

// Back button — peel de ConversationViewChrome+Header.

extension ConversationView {
    var headerBackButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
        }
        .accessibilityLabel("voltar")
        .accessibilityHint("fecha a conversa")
    }
}
