import SwiftUI

// Ações Preparar/hoje não/pausar — peel de NightlyProposalCard.
// Mute → NightlyProposalCard+Mute.swift
// Dismiss → NightlyProposalCard+Dismiss.swift

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
            dismissButton
            muteMenu
        }
    }
}
