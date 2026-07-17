import SwiftUI
import UIKit
import AtlasCore

// FAB + scroll coalescing — peel de ConversationMessages.
// FAB → ConversationMessages+ScrollFAB.swift
// Key → ConversationMessages+ScrollKey.swift
// Auto → ConversationMessages+ScrollAuto.swift
// Preference → ConversationMessages+ScrollPreference.swift

extension ConversationMessages {
    var showsScrollFAB: Bool { awayFromBottom && !model.bubbles.isEmpty }

    @ViewBuilder
    func scrollChrome<Content: View>(proxy: ScrollViewProxy, @ViewBuilder content: () -> Content) -> some View {
        scrollPreferenceChrome(proxy: proxy, content: content)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: showsScrollFAB)
            .onChange(of: model.bubbles.isEmpty) { _, empty in
                if empty { awayFromBottom = false }
            }
            .onChange(of: model.bubbles) {
                autoScrollToBottom(proxy: proxy)
            }
    }
}
