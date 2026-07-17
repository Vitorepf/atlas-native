import SwiftUI
import UIKit
import AtlasCore

// Strip de anexos do composer — renderiza LocalDraft e nada mais
// (contrato único de UI de anexos). Thumb → DraftThumb.swift.
// Thumbs → DraftStrip+Thumbs.swift

struct DraftStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        if drafts.isEmpty {
            EmptyView()
        } else {
            draftThumbs
        }
    }
}
