import SwiftUI
import UIKit
import AtlasCore

// FAB scroll action — peel de ConversationMessages+ScrollFAB.

extension ConversationMessages {
    func scrollFABAction(proxy: ScrollViewProxy) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }
}
