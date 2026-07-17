import SwiftUI
import AtlasCore

// Ask pill a11y chrome — peel de AtlasCodeView+AskPillChrome.
// Traits → AtlasCodeView+AskPillA11yTraits.swift

extension AtlasCodeView {
    var askPillA11yChrome: some View {
        askPillA11yTraits(
            askPillContent
                .onTapGesture {
                    AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                    askDraft = ""
                    showsAskCard = true
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.bottom, 10)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 0.22),
                    value: AtlasCodeAskPillA11y.pillPhaseID(
                        isAnchoring: askModel.isAnchoring,
                        anchorLegend: anchorLegend
                    )
                )
        )
    }
}
