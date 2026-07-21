import SwiftUI

/// Card da proposta noturna — masthead + copy + Preparar/hoje não/silenciar.
struct NightlyProposalCard: View {
    let proposal: NightlyProposalController.ProposalPayload
    let onAccept: () -> Void
    /// Silêncio: some o card sem toast, sem confirmação, sem fila.
    let onDismiss: () -> Void
    let onMute: (Int) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    /// Hora aprendida do fim do dia — masthead diz o ritmo real, não "21h" fixo.
    @State private var learnedDayEnd: String?

    static let muteDays = [1, 3, 7]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            masthead
            copyBlock
            actionRow
        }
        .padding(14)
        .atlasCard(cornerRadius: AtlasTheme.Radius.card)
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.nightlyProposalCard)
        .task {
            let windows = await AtlasSession.rhythm.windows(minimumDays: 4)
            learnedDayEnd = AutonomosRhythmCopy.hour(windows.dayEnd)
        }
    }

    private var masthead: some View {
        HStack(spacing: 8) {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                .accessibilityHidden(true)
            Text(learnedDayEnd.map { "MISSÃO NOTURNA · NO SEU RITMO (~\($0))" }
                ?? "MISSÃO NOTURNA · NO SEU RITMO")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }

    private var copyBlock: some View {
        Group {
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
        }
    }

    private var actionRow: some View {
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

    // MARK: - Spoken

    static func spokenCardLabel(workspaceText: String) -> String {
        "missão noturna proposta. Hoje você trabalhou em \(workspaceText). "
            + "A frota pode continuar enquanto você descansa."
    }

    static func spokenCardHint() -> String {
        "preparar, descartar em silêncio ou silenciar por dias"
    }

    static func spokenAcceptLabel() -> String { "preparar missão noturna" }
    static func spokenAcceptHint() -> String {
        "abre o ensaio governado da missão noturna"
    }
    static func spokenDismissLabel() -> String { "hoje não" }
    static func spokenDismissHint() -> String {
        "descarta a proposta em silêncio, sem confirmação"
    }
    static func spokenMuteMenuLabel() -> String { "silenciar propostas noturnas" }
    static func spokenMuteMenuHint() -> String {
        "oculta card e notificações por 1, 3 ou 7 dias, em silêncio"
    }
    static func spokenMuteOption(days: Int) -> String {
        "silenciar por \(days) \(days == 1 ? "dia" : "dias")"
    }
    static func spokenMuteOptionHint() -> String {
        "remove a proposta e pausa notificações, sem toast"
    }
}
