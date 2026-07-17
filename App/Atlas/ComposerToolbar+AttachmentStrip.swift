import SwiftUI
import AtlasCore

// Faixa de anexos + progresso de upload — peel de ComposerToolbar.
// Upload → ComposerToolbar+AttachmentStripUpload.swift

struct AttachmentStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let uploadPercent: Double?
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        if isVisible {
            Group {
                if !drafts.isEmpty {
                    DraftStrip(drafts: drafts, reduceMotion: reduceMotion,
                               onRemove: onRemove, onFailedTap: onFailedTap)
                }
                uploadProgressRow
            }
            .accessibilityIdentifier(A11yID.composerAttachmentStrip)
        }
    }
}
