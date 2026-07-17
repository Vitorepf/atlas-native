import SwiftUI
import AtlasCore

// Ask pill a11y chrome — peel de AtlasCodeView+AskPillChrome.

extension AtlasCodeView {
    var askPillA11yChrome: some View {
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
            .accessibilityElement(children: .contain)
            .accessibilityLabel(
                AtlasCodeAskPillA11y.spokenPill(
                    isAnchoring: askModel.isAnchoring,
                    anchorLegend: anchorLegend
                )
            )
            .accessibilityHint(AtlasCodeAskPillA11y.pillHint)
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier(A11yID.codeAskPill)
    }
}
