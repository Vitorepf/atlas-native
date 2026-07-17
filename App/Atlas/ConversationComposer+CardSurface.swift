import SwiftUI
import AtlasCore

// Composer card surface — peel de ConversationComposer+Card.

extension ConversationComposer {
    var composerCardSurface: some View {
        VStack(alignment: .leading, spacing: expanded ? 12 : 0) {
            composerCardBody
        }
        .padding(composerCardPadding)
        .background(composerSurface)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.86), value: expanded)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.86), value: model.drafts)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(composerCardSpokenLabel)
        .accessibilityHint(ConversationComposerA11y.cardHint)
    }
}
