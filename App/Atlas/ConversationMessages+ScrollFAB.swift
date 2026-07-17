import SwiftUI
import UIKit
import AtlasCore

// FAB overlay — peel de ConversationMessages+Scroll.
// Label → ConversationMessages+ScrollFABLabel.swift

extension ConversationMessages {
    @ViewBuilder
    func scrollFAB(proxy: ScrollViewProxy) -> some View {
        if showsScrollFAB {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            } label: {
                scrollFABLabel
            }
            .buttonStyle(PressableScale())
            .padding(.trailing, AtlasTheme.Space.screen).padding(.bottom, 110)
            .transition(reduceMotion ? .opacity : .scale(scale: 0.8).combined(with: .opacity))
            .accessibilityLabel(ConversationMessagesA11y.scrollFABLabel)
            .accessibilityHint(ConversationMessagesA11y.scrollFABHint)
            .accessibilityIdentifier(A11yID.conversationScrollFAB)
        }
    }
}
