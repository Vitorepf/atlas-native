import SwiftUI

// Mute menu — peel de NightlyProposalCard+Actions.

extension NightlyProposalCard {
    var muteMenu: some View {
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
