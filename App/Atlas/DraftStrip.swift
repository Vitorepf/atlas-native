import AtlasCore
import SwiftUI
import UIKit

// Cycle 041 fuse → DraftStrip.swift

// Strip de anexos do composer — renderiza LocalDraft e nada mais

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
