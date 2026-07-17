import SwiftUI
import UIKit

// Attachment row — peel de ComposerAttachmentsSheet.
// Copy → ConversationChrome+ComposerSheets+AttachmentCopy.swift

struct ComposerAttachmentRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        attachmentRowCopy
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(title), \(subtitle)")
    }
}
