import SwiftUI
import UIKit
import AtlasCore

// Thumb loop — peel de DraftStrip+Thumbs.

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
