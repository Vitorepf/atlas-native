import SwiftUI
import UIKit
import AtlasCore

// FAB overlay — peel de ConversationMessages+Scroll.

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
                Image(systemName: "arrow.down")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AtlasTheme.surfaceHi)
                        .overlay(Circle().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                        .shadow(color: .black.opacity(0.25), radius: 8, y: 2))
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
