import SwiftUI

// Ações Preparar/hoje não/silenciar — peel de NightlyProposalCard.
// Mute → NightlyProposalCard+Mute.swift

extension NightlyProposalCard {
    var actionRow: some View {
        HStack(spacing: 10) {
            Button("Preparar missão noturna") {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onAccept()
            }
            .buttonStyle(AutonomosPrimaryButtonStyle())
            .accessibilityIdentifier(A11yID.nightlyProposalAccept)
            .accessibilityLabel(Self.spokenAcceptLabel())
            .accessibilityHint(Self.spokenAcceptHint())
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
            muteMenu
        }
    }
}
