import SwiftUI

// Dismiss button — peel de NightlyProposalCard+Actions.

extension NightlyProposalCard {
    var dismissButton: some View {
        Button("hoje não") {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onDismiss()
        }
        .font(.system(.footnote, weight: .semibold))
        .foregroundStyle(AtlasTheme.textTertiary)
        .buttonStyle(PressableScale())
        .accessibilityIdentifier(A11yID.nightlyProposalDismiss)
        .accessibilityLabel(Self.spokenDismissLabel())
        .accessibilityHint(Self.spokenDismissHint())
    }
}
