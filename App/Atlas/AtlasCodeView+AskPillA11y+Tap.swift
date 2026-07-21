import SwiftUI
import AtlasCore

// Ask pill tap — peel de AtlasCodeView+AskPillA11y.

extension AtlasCodeView {
    func askPillTapGesture<V: View>(_ content: V) -> some View {
        content.onTapGesture {
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            // Com âncora de swipe, o draft já está semeado — não apagar.
            if askFocusNode == nil {
                askDraft = ""
            }
            showsAskCard = true
        }
    }
}
