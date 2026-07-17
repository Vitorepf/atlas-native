import SwiftUI
import UIKit
import AtlasCore

// Draft thumbs HStack — peel de DraftStrip.
// Loop → DraftStrip+Thumbs+ThumbLoop.swift

extension DraftStrip {
    var draftThumbs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            draftThumbLoop
        }
        .scrollClipDisabled()   // o ✕ vaza do thumb; sem isto o clip corta o alvo
        .accessibilityElement(children: .contain)
        .accessibilityLabel(DraftStripA11y.spokenStrip(draftCount: drafts.count))
        .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.86),
                   value: drafts.map(\.id))
    }
}
