import Foundation
import AtlasCore

/// Spoken labels do feed de turnos — peel de ConversationMessages (CICLO C residual honesty).
/// Review → ConversationMessages+A11yReview.swift
/// FAB → ConversationMessages+A11yFAB.swift

enum ConversationMessagesA11y {
    static let scrollFABLabel = ConversationMessagesA11yFAB.scrollFABLabel
    static let scrollFABHint = ConversationMessagesA11yFAB.scrollFABHint

    static func spokenMessages(turnCount: Int) -> String {
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "conversa, \(turnCount) \(noun)"
    }

    static func spokenChangeReview(patchCount: Int) -> String {
        ConversationMessagesA11yReview.spokenChangeReview(patchCount: patchCount)
    }

    static let changeReviewHint = ConversationMessagesA11yReview.changeReviewHint
}
