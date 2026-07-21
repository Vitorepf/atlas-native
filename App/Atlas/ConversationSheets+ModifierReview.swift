import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Review/artifact/queue sheets — peel de ConversationSheets+Modifier.
// ChangeReview → ConversationSheets+ModifierReview+ChangeReview.swift
// Queue → ConversationSheets+ModifierReview+Queue.swift
// Steer → ConversationSheets+ModifierSteer.swift

extension ConversationComposerSheetsModifier {
    func reviewSteerQueueSheets<Content: View>(on content: Content) -> some View {
        steerSheet(on: queueSheet(on: changeReviewSheets(on: content)))
    }
}
