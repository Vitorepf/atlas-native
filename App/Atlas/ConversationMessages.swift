import SwiftUI
import AtlasCore

// IDLE-COMPRESS fused ConversationMessages · ConversationMessages.swift

// --- ConversationMessages.swift ---
struct ConversationMessages: View {
    var model: ConversationModel
    var reduceMotion: Bool
    var emptyPrompt: String?
    var emptySuggestions: [String]?
    @Environment(AtlasSession.self) var session
    @Binding var awayFromBottom: Bool
    @Binding var lastScrollAt: CFAbsoluteTime
    @Binding var lastScrollBubbleCount: Int
    @Binding var reviewTrace: ConversationReviewTraceRef?
    @Binding var artifactTrace: ConversationReviewTraceRef?
    @Binding var steerTrace: ConversationSteerTraceRef?
    var onEditResend: (ChatBubble) -> Void
    var onCopy: (String, String) -> Void

    var body: some View {
        messagesReaderBody
    }
}

// --- ConversationMessages+Empty.swift ---
extension ConversationMessages {
    @ViewBuilder
    func emptyMessages() -> some View {
        if model.loadError != nil {
            AtlasNetworkFailureEmpty(
                kind: model.loadFailureKind,
                hasToken: session.hasToken,
                host: session.host,
                topPadding: 100,
                retryHint: "reconecta e recarrega esta conversa",
                accessibilityIdentifier: A11yID.conversationLoadFailure,
                onRetry: { Task { await model.load() } }
            )
        } else {
            EmptyConversation(
                reduceMotion: reduceMotion,
                prompt: emptyPrompt,
                suggestions: emptySuggestions
            ) { suggestion in
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                let effort = model.effort
                Task { await model.send(suggestion, effort: effort) }
            }
        }
    }
}

// --- ConversationMessages+Scroll+BubbleLifecycle+EmptyChange.swift ---
extension ConversationMessages {
    func scrollBubbleEmptyChange(_ empty: Bool) {
        if empty { awayFromBottom = false }
    }
}

// --- ConversationMessages+Scroll+BubbleLifecycle+ListChange.swift ---
extension ConversationMessages {
    func scrollBubbleListChange(proxy: ScrollViewProxy) {
        autoScrollToBottom(proxy: proxy)
    }
}

// --- ConversationMessages+Scroll+ChromeChain.swift ---
extension ConversationMessages {
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

// --- ConversationMessages+Scroll+FABGate.swift ---
extension ConversationMessages {
    var showsScrollFAB: Bool { awayFromBottom && !model.bubbles.isEmpty }
}

// --- ConversationMessages+ScrollAuto.swift ---
extension ConversationMessages {
    func autoScrollToBottom(proxy: ScrollViewProxy) {
        guard !model.bubbles.isEmpty else { return }
        let count = model.bubbles.count
        let now = CFAbsoluteTimeGetCurrent()
        guard shouldAutoScroll(now: now, count: count) else { return }
        lastScrollAt = now
        lastScrollBubbleCount = count
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }
}

// --- ConversationMessages+ScrollAutoGate.swift ---
extension ConversationMessages {
    func shouldAutoScroll(now: CFAbsoluteTime, count: Int) -> Bool {
        let countChanged = count != lastScrollBubbleCount
        return countChanged || now - lastScrollAt >= 0.1
    }
}

// --- ConversationMessages+ScrollDistancePref.swift ---
extension ConversationMessages {
    func applyScrollDistancePref<Content: View>(_ content: Content) -> some View {
        content.onPreferenceChange(BottomDistanceKey.self) { minY in
            guard !model.bubbles.isEmpty else {
                awayFromBottom = false
                return
            }
            awayFromBottom = minY > UIScreen.main.bounds.height + 140
        }
    }
}

// --- ConversationMessages+ScrollFAB+Action.swift ---
extension ConversationMessages {
    func scrollFABAction(proxy: ScrollViewProxy) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }
}

// --- ConversationMessages+ScrollFAB+Button.swift ---
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

// --- ConversationMessages+ScrollFAB.swift ---
extension ConversationMessages {
    @ViewBuilder
    func scrollFAB(proxy: ScrollViewProxy) -> some View {
        if showsScrollFAB {
            scrollFABChrome(scrollFABButton(proxy: proxy))
        }
    }
}

// --- ConversationMessages+ScrollFABChrome.swift ---
extension ConversationMessages {
    func scrollFABChrome<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(PressableScale())
            .padding(.trailing, AtlasTheme.Space.screen).padding(.bottom, 110)
            .transition(reduceMotion ? .opacity : .scale(scale: 0.8).combined(with: .opacity))
            .accessibilityLabel(ConversationMessagesA11y.scrollFABLabel)
            .accessibilityHint(ConversationMessagesA11y.scrollFABHint)
            .accessibilityIdentifier(A11yID.conversationScrollFAB)
    }
}

