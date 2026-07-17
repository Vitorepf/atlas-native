import SwiftUI
import UIKit

// Copy visual do attachment row — peel de ConversationChrome+ComposerSheets+AttachmentRow.
// Icon → ConversationChrome+ComposerSheets+AttachmentCopy+Icon.swift
// TextStack → ConversationChrome+ComposerSheets+AttachmentCopy+TextStack.swift

extension ComposerAttachmentRow {
    var attachmentRowCopy: some View {
        HStack(spacing: 14) {
            attachmentRowIcon
            attachmentRowTextStack
            Spacer()
        }
        .padding(.horizontal, 24).padding(.vertical, 15)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) { Divider().overlay(AtlasTheme.separator).padding(.leading, 24) }
    }
}
