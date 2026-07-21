import AtlasCore
import SwiftUI

// Cycle 029 fuse → ConversationMessages.swift

// Scroll chrome: ConversationMessages+Scroll.swift
// Empty + bubbles: ConversationMessages+List.swift

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

extension ConversationMessages {
    @ViewBuilder
    func messagesList() -> some View {
        if model.bubbles.isEmpty {
            emptyMessages()
        } else {
            bubblesStack
        }
    }
}

extension ConversationMessages {
    var messagesReaderBody: some View {
        ScrollViewReader { proxy in
            scrollChrome(proxy: proxy) {
                ScrollView {
                    messagesList()
                }
            }
        }
    }
}

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
            emptyConversationBody
        }
    }
}

extension ConversationMessages {
    @ViewBuilder
    var emptyConversationBody: some View {
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
