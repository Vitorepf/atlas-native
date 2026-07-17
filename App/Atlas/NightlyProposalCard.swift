import SwiftUI

struct NightlyProposalCard: View {
    let proposal: NightlyProposalController.ProposalPayload
    let onAccept: () -> Void
    /// Silêncio: some o card sem toast, sem confirmação, sem fila.
    let onDismiss: () -> Void
    let onMute: (Int) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let muteDays = [1, 3, 7]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                    .accessibilityHidden(true)
                Text("MISSÃO NOTURNA · PROPOSTA DAS 21H")
                    .font(AtlasFont.mono(10))
                    .tracking(1.1)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            Text("Hoje você trabalhou em \(proposal.workspaceText).")
                .font(AtlasFont.serif(16, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            Text("A frota pode continuar enquanto você descansa.")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
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
        .padding(14)
        .atlasCard(cornerRadius: 14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.nightlyProposalCard)
        .accessibilityLabel(Self.spokenCardLabel(workspaceText: proposal.workspaceText))
        .accessibilityHint(Self.spokenCardHint())
    }
}
