import SwiftUI
import AtlasCore

// Row transition — peel de LiveNowSection+RowCell.

extension LiveNowSection {
    func liveNowRowTransition<Content: View>(_ content: Content) -> some View {
        content.transition(reduceMotion ? .opacity : .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 8)),
            removal: .opacity
        ))
    }
}
