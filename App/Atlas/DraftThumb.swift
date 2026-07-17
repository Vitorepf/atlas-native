import SwiftUI
import UIKit
import AtlasCore

// Thumb de anexo do composer — peel de DraftStrip.
// Cache → +Cache · remove/veil → +Chrome · spoken → +A11y · Image → +Image.
// Failed → DraftThumb+Failed.swift
// Content → DraftThumb+Content.swift
struct DraftThumb: View {
    let draft: LocalDraft
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            thumbContent
            removeButton
        }
    }
}
