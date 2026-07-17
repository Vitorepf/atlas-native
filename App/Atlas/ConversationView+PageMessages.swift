import SwiftUI
import PhotosUI
import AtlasCore

// ConversationMessages bind — peel de ConversationView+PageParts.
// Model → ConversationView+PageMessages+Model.swift
// Trace → ConversationView+PageMessages+Trace.swift

extension ConversationView {
    var conversationMessagesView: some View {
        let modelArgs = conversationMessagesModelArgs
        let traceArgs = conversationMessagesTraceArgs
        return ConversationMessages(
            model: modelArgs.model,
            reduceMotion: modelArgs.reduceMotion,
            emptyPrompt: modelArgs.emptyPrompt,
            emptySuggestions: modelArgs.emptySuggestions,
            awayFromBottom: traceArgs.awayFromBottom,
            lastScrollAt: traceArgs.lastScrollAt,
            lastScrollBubbleCount: traceArgs.lastScrollBubbleCount,
            reviewTrace: traceArgs.reviewTrace,
            artifactTrace: traceArgs.artifactTrace,
            steerTrace: traceArgs.steerTrace,
            onEditResend: traceArgs.onEditResend,
            onCopy: traceArgs.onCopy
        )
    }
}
