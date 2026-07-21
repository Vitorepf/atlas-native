import SwiftUI
import AtlasCore

// Faixa de anexos + progresso de upload — peel de ComposerToolbar.
// Upload → ComposerToolbar+AttachmentStripUpload.swift
// Draft → ComposerToolbar+AttachmentStrip+DraftBranch.swift

struct AttachmentStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let uploadPercent: Double?
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        if isVisible {
            Group {
                attachmentDraftBranch
                uploadProgressRow
            }
            .accessibilityIdentifier(A11yID.composerAttachmentStrip)
        }
    }
}
