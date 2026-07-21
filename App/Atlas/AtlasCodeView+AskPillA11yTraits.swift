import SwiftUI
import AtlasCore

// Ask pill a11y traits — peel de AtlasCodeView+AskPillA11y.

extension AtlasCodeView {
    func askPillA11yTraits<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .contain)
            .accessibilityLabel(
                AtlasCodeAskPillA11y.spokenPill(
                    isAnchoring: pillIsAnchoring,
                    anchorLegend: anchorLegend
                )
            )
            .accessibilityHint(AtlasCodeAskPillA11y.pillHint)
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier(A11yID.codeAskPill)
    }
}
