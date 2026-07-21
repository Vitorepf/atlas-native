import SwiftUI
import AtlasCore

// Conteúdo visual da pílula — chrome canônico Home (uma família visual).

extension AtlasCodeView {
    @ViewBuilder
    var askPillContent: some View {
        askPillLeading
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .atlasAgenticPillChrome()
            .contentShape(Capsule())
    }
}
