import SwiftUI
import UIKit
import AtlasCore

// FAB button — peel de ConversationMessages+ScrollFAB.

extension ConversationMessages {
    @ViewBuilder
    func scrollFABButton(proxy: ScrollViewProxy) -> some View {
        Button {
            scrollFABAction(proxy: proxy)
        } label: {
            scrollFABLabel
        }
    }
}
