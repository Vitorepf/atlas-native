import SwiftUI
import UIKit
import AtlasCore

// Strip de anexos do composer — renderiza LocalDraft e nada mais
// (contrato único de UI de anexos). Thumb → DraftThumb.swift.

struct DraftStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(drafts) { d in
                    DraftThumb(draft: d, onRemove: onRemove, onFailedTap: onFailedTap)
                        .transition(reduceMotion ? .opacity
                                    : .scale(scale: 0.86).combined(with: .opacity))
                }
            }
            .padding(.top, 6).padding(.trailing, 6)
        }
        .scrollClipDisabled()   // o ✕ vaza do thumb; sem isto o clip corta o alvo
    }
}
