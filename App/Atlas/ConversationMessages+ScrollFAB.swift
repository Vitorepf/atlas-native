import SwiftUI
import UIKit
import AtlasCore

// FAB overlay — peel de ConversationMessages+Scroll.
// Label → ConversationMessages+ScrollFABLabel.swift
// Chrome → ConversationMessages+ScrollFABChrome.swift

extension ConversationMessages {
    @ViewBuilder
    func scrollFAB(proxy: ScrollViewProxy) -> some View {
        if showsScrollFAB {
            scrollFABChrome(scrollFABButton(proxy: proxy))
        }
    }
}
