import SwiftUI
import AtlasCore

// Turno editorial — extraído de ConversationChrome (CICLO B compressão).
// Assinatura/feedback → EditorialTurnChrome; empty/failure → ConversationEmptyStates.
// Assistant stack → EditorialTurn+Assistant.swift
// Arrival → EditorialTurn+Arrival.swift
// Equatable → EditorialTurn+Equatable.swift
// Body → EditorialTurn+Body.swift

struct EditorialTurn: View, Equatable {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onFeedback: (FeedbackKind) -> Void
    let onCopy: () -> Void
    var onEditResend: () -> Void = {}
    let onStop: () -> Void
    let onExecutionChoice: (JobID, String) -> Void
    var onRetry: (JobID) -> Void = { _ in }
    var onSteer: (TraceID) -> Void = { _ in }
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @State var placed = false

    var body: some View {
        applyArrival(turnBody)
    }
}
