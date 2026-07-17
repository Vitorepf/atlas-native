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
            scrollFABChrome(
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                } label: {
                    scrollFABLabel
                }
            )
        }
    }
}
