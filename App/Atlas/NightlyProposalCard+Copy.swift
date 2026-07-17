import SwiftUI

// Masthead — peel de NightlyProposalCard.
// Copy → NightlyProposalCard+CopyBody.swift

extension NightlyProposalCard {
    var masthead: some View {
        HStack(spacing: 8) {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                .accessibilityHidden(true)
            Text("MISSÃO NOTURNA · PROPOSTA DAS 21H")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
