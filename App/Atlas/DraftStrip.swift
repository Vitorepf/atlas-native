import SwiftUI
import UIKit
import AtlasCore

// Strip de anexos do composer — LocalDraft only (WAVE-086 Judgment).

struct DraftStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void
    var uploadPercent: Double? = nil

    private var stripFace: ComposerDraftStripFace {
        ComposerDraftJudgment.stripFace(drafts: drafts, uploadPercent: uploadPercent)
    }

    var body: some View {
        if stripFace == .silence {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // WAVE-046/086: failed-first attention rank.
                    ForEach(ComposerDraftJudgment.rankDrafts(drafts)) { d in
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
            .accessibilityLabel(
                ComposerDraftJudgment.spokenStrip(drafts: drafts, uploadPercent: uploadPercent)
            )
            .accessibilityValue(stripFace.productWord)
            .animation(
                reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.86),
                value: drafts.map(\.id)
            )
        }
    }
}
