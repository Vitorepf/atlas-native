import SwiftUI
import AtlasCore

// Turno editorial — extraído de ConversationChrome (CICLO B compressão).
// Assinatura/feedback → EditorialTurnChrome; empty/failure → ConversationEmptyStates.
// Assistant stack → EditorialTurn+Assistant.swift
// Arrival → EditorialTurn+Arrival.swift

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

    // F2.10: igualdade só no que a tela mostra — closures recriadas pelo pai
    // não invalidam o subtree (pare com `.equatable()` no call site).
    nonisolated static func == (lhs: EditorialTurn, rhs: EditorialTurn) -> Bool {
        lhs.bubble == rhs.bubble && lhs.reduceMotion == rhs.reduceMotion && lhs.artifactItems == rhs.artifactItems
    }

    var body: some View {
        applyArrival(
            Group {
                if bubble.role == "user" {
                    userTurn
                } else {
                    assistantTurn
                }
            }
        )
    }
}
