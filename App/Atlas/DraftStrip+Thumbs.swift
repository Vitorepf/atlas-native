import SwiftUI
import UIKit
import AtlasCore

// Draft thumbs HStack — peel de DraftStrip.

extension DraftStrip {
    var draftThumbs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
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
        .scrollClipDisabled()   // o ✕ vaza do thumb; sem isto o clip corta o alvo
        .accessibilityElement(children: .contain)
        .accessibilityLabel(DraftStripA11y.spokenStrip(draftCount: drafts.count))
        .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.86),
                   value: drafts.map(\.id))
    }
}
