import SwiftUI

// Ações Preparar/hoje não/silenciar — peel de NightlyProposalCard.

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
            Menu("silenciar") {
                ForEach(Self.muteDays, id: \.self) { days in
                    Button("\(days) dia\(days == 1 ? "" : "s")") {
                        AtlasMotion.softImpact(reduceMotion: reduceMotion)
                        onMute(days)
                    }
                    .accessibilityLabel(Self.spokenMuteOption(days: days))
                    .accessibilityHint(Self.spokenMuteOptionHint())
                }
            }
            .font(.system(.footnote, weight: .semibold))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityIdentifier(A11yID.nightlyProposalMute)
            .accessibilityLabel(Self.spokenMuteMenuLabel())
            .accessibilityHint(Self.spokenMuteMenuHint())
        }
    }
}
