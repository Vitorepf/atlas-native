import SwiftUI
import UIKit
import AtlasCore

// Strip de anexos do composer — LocalDraft only (IDLE-COMPRESS).

struct DraftStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        if drafts.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // WAVE-046: failed-first attention rank.
                    ForEach(ComposerSendJudgment.rankDrafts(drafts)) { d in
                        DraftThumb(
                            draft: d,
                            reduceMotion: reduceMotion,
                            onRemove: onRemove,
                            onFailedTap: onFailedTap
                        )
                        .transition(
                            reduceMotion
                                ? .opacity
                                : .scale(scale: 0.86).combined(with: .opacity)
                        )
                    }
                }
                .padding(.top, 6).padding(.trailing, 6)
            }
            .scrollClipDisabled()
            .accessibilityElement(children: .contain)
            .accessibilityLabel(DraftStripA11y.spokenStrip(draftCount: drafts.count))
            .animation(
                reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.86),
                value: drafts.map(\.id)
            )
        }
    }
}

enum DraftStripA11y {
    static func spokenStrip(draftCount: Int) -> String {
        let noun = draftCount == 1 ? "anexo" : "anexos"
        return "\(draftCount) \(noun) no composer"
    }
}
