import SwiftUI
import AtlasCore

// Ask pill padding + motion — peel de AtlasCodeView+AskPillA11y.

extension AtlasCodeView {
    func askPillPaddingAnimation<V: View>(_ content: V) -> some View {
        content
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.bottom, 10)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 0.22),
                value: AtlasCodeAskPillA11y.pillPhaseID(
                    isAnchoring: askModel.isAnchoring,
                    anchorLegend: anchorLegend
                )
            )
    }
}
