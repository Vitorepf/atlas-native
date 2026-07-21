import SwiftUI
import AtlasCore

// EditorialTurn assembly — peel de ConversationMessages+RowsTurn.
// ExecTuple → ConversationMessages+RowsTurn+Assembly+ExecTuple.swift
// SteerTuple → ConversationMessages+RowsTurn+Assembly+SteerTuple.swift
// Built → ConversationMessages+RowsTurn+Assembly+Built.swift

extension ConversationMessages {
    func editorialTurnAssembly(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item],
        exec: (
            onFeedback: (FeedbackKind) -> Void,
            onCopy: () -> Void,
            onEditResend: () -> Void,
            onStop: () -> Void,
            onExecutionChoice: (JobID, String) -> Void,
            onRetry: (JobID) -> Void
        ),
        steer: (
            onSteer: (TraceID) -> Void,
            onOpenArtifacts: (TraceID) -> Void
        )
    ) -> EditorialTurn {
        EditorialTurn(
            bubble: bubble,
            reduceMotion: reduceMotion,
            onFeedback: exec.onFeedback,
            onCopy: exec.onCopy,
            onEditResend: exec.onEditResend,
            onStop: exec.onStop,
            onExecutionChoice: exec.onExecutionChoice,
            onRetry: exec.onRetry,
            onSteer: steer.onSteer,
            artifactItems: artifactItems,
            onOpenArtifacts: steer.onOpenArtifacts
        )
    }
}
