import SwiftUI
import UIKit
import AtlasCore

// FAB + scroll coalescing — peel de ConversationMessages.
// FAB → ConversationMessages+ScrollFAB.swift
// Lifecycle → ConversationMessages+Scroll+BubbleLifecycle.swift

extension ConversationMessages {
    var showsScrollFAB: Bool { awayFromBottom && !model.bubbles.isEmpty }

    @ViewBuilder
    func scrollChrome<Content: View>(proxy: ScrollViewProxy, @ViewBuilder content: () -> Content) -> some View {
        scrollPreferenceChrome(proxy: proxy, content: content)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: showsScrollFAB)
            .onChange(of: model.bubbles.isEmpty) { _, empty in
                scrollBubbleEmptyChange(empty)
            }
            .onChange(of: model.bubbles) {
                scrollBubbleListChange(proxy: proxy)
            }
    }
}
