import AtlasCore
import Foundation
import SwiftUI
import UIKit

// Cycle 043 fuse → DraftStrip.swift

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

enum DraftStripA11y {
    static func spokenStrip(draftCount: Int) -> String {
        let noun = draftCount == 1 ? "anexo" : "anexos"
        return "\(draftCount) \(noun) no composer"
    }
}

extension DraftStrip {
    var draftThumbLoop: some View {
        HStack(spacing: 12) {
            ForEach(drafts) { d in
                DraftThumb(draft: d, reduceMotion: reduceMotion,
                           onRemove: onRemove, onFailedTap: onFailedTap)
                    .transition(reduceMotion ? .opacity
                                : .scale(scale: 0.86).combined(with: .opacity))
            }
        }
        .padding(.top, 6).padding(.trailing, 6)
    }
}

extension DraftStrip {
    var draftThumbs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            draftThumbLoop
        }
        .scrollClipDisabled()   // o ✕ vaza do thumb; sem isto o clip corta o alvo
        // Contain without strip label: each DraftThumb keeps its own a11y node.
        .accessibilityElement(children: .contain)
        .animation(
            reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.82),
            value: drafts.map(\.id)
        )
    }
}
