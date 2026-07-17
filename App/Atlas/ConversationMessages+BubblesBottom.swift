import SwiftUI
import AtlasCore

// Bottom scroll anchor — peel de ConversationMessages+BubblesStack.

extension ConversationMessages {
    var bubblesBottomAnchor: some View {
        Color.clear.frame(height: 96).id("bottom")
            .background(GeometryReader { geo in
                Color.clear.preference(key: BottomDistanceKey.self,
                                       value: geo.frame(in: .global).minY)
            })
    }
}
