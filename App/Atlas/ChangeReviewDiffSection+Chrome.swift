import SwiftUI
import AtlasCore

// Patch card chrome — peel de ChangeReviewDiffSection.

extension ChangeReviewPatchCard {
    func patchCardChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .atlasCard()
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ChangeReviewPatchA11y.spokenCard(patch: patch, diffExpanded: diffExpanded))
            .accessibilityIdentifier(A11yID.reviewPatchCard(patch.id))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: diffExpanded)
    }
}
