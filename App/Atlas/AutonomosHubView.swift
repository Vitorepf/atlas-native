import SwiftUI

/// Hub de um Autônomo do operador — presença → fato → verbo → Evolução.
/// Vestimenta = `AutonomosHubVestment` canônico (WAVE-007); zero LocalVestment.
struct AutonomosHubView: View {
    let unit: AutonomosUnit
    let vestment: AutonomosHubVestment
    let onNavigate: (AutonomosDestination) -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onEnd: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AutonomosMapChrome.kicker(kickerLine, live: vestment.kickerLive)
                    .padding(.bottom, 14)
                AutonomosMapChrome.heroTitle(vestment.heroTitle)
                    .padding(.bottom, 10)
                Text(unit.charter)
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 28)

                primaryVerb
                    .padding(.bottom, 8)

                AutonomosMapChrome.hairline
                    .padding(.top, 12)
                    .padding(.bottom, 10)

                AutonomosMapNavLine(
                    title: "Evolução",
                    meta: "ainda sem provas",
                    action: { onNavigate(.evolution) }
                )

                if unit.paused {
                    AutonomosMapNavLine(title: "Encerrar", meta: "", action: onEnd)
                } else {
                    AutonomosMapNavLine(title: "Pausar", meta: "", action: onPause)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .padding(.bottom, 140)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier(A11yID.autonomosHub)
        .accessibilityLabel(hubSpokenLabel)
    }

    private var kickerLine: String {
        "\(vestment.kicker) · \(unit.ageLabel)"
    }

    private var hubSpokenLabel: String {
        "\(unit.name), \(vestment.spokenFace), \(vestment.heroTitle)"
    }

    @ViewBuilder
    private var primaryVerb: some View {
        switch vestment {
        case .quiet:
            AutonomosMapChrome.primaryCTA("Retomar", action: onResume)
        case .live, .awaiting:
            EmptyView()
        }
    }
}
