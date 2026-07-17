import SwiftUI

struct NightlyProposalCard: View {
    let proposal: NightlyProposalController.ProposalPayload
    let onAccept: () -> Void
    /// Silêncio: some o card sem toast, sem confirmação, sem fila.
    let onDismiss: () -> Void
    let onMute: (Int) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                    .accessibilityHidden(true)
                Text("MISSÃO NOTURNA · PROPOSTA DAS 21H")
                    .font(AtlasFont.mono(10))
                    .tracking(1.1)
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            Text("Hoje você trabalhou em \(proposal.workspaceText).")
                .font(AtlasFont.serif(16, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text("A frota pode continuar enquanto você descansa.")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 10) {
                Button("Preparar missão noturna", action: onAccept)
                    .buttonStyle(NightlyPrimaryButtonStyle())
                    .accessibilityIdentifier(A11yID.nightlyProposalAccept)
                    .accessibilityHint("abre o ensaio governado da missão noturna")
                Button("hoje não", action: onDismiss)
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .buttonStyle(PressableScale())
                    .accessibilityIdentifier(A11yID.nightlyProposalDismiss)
                    .accessibilityHint("descarta em silêncio")
                Menu("silenciar") {
                    Button("1 dia") { onMute(1) }
                    Button("3 dias") { onMute(3) }
                    Button("7 dias") { onMute(7) }
                }
                .font(.system(.footnote, weight: .semibold))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityIdentifier(A11yID.nightlyProposalMute)
                .accessibilityLabel("silenciar propostas noturnas")
                .accessibilityHint("oculta propostas por 1, 3 ou 7 dias, em silêncio")
            }
        }
        .padding(14)
        .atlasCard(cornerRadius: 14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.nightlyProposalCard)
        .accessibilityLabel(
            "missão noturna proposta. Hoje você trabalhou em \(proposal.workspaceText). "
            + "A frota pode continuar enquanto você descansa."
        )
        .animation(reduceMotion ? nil : AtlasMotion.arrival, value: proposal.id)
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
    }
}

struct NightlyPrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.footnote, weight: .semibold))
            .foregroundStyle(AtlasTheme.bg)
            .padding(.horizontal, 13)
            .padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.accent.opacity(configuration.isPressed ? 0.72 : 1)))
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
