import SwiftUI

/// Hub de um Autônomo do operador — presença → fato → verbo → Evolução.
/// Sem backlog de área de sistema. Sem número mentiroso.
struct AutonomosHubView: View {
    let unit: AutonomosUnit
    let onNavigate: (AutonomosDestination) -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onEnd: () -> Void

    private var vestment: LocalVestment {
        unit.paused ? .quiet : .live
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AutonomosMapChrome.kicker(kickerLine, live: !unit.paused)
                    .padding(.bottom, 14)
                    .accessibilityHidden(true)
                AutonomosMapChrome.heroTitle(vestment.hero)
                    .padding(.bottom, 10)
                    .accessibilityLabel("\(unit.name), \(vestment.hero), \(kickerLine)")
                    .accessibilityAddTraits(.isHeader)
                Text(unit.charter)
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 28)
                    .accessibilityLabel(unit.charter)

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
                    AutonomosMapNavLine(title: "Encerrar", meta: "", danger: true, action: onEnd)
                } else {
                    // Medium: Pausar is a governed presence commit (mirrors Retomar).
                    AutonomosMapNavLine(title: "Pausar", meta: "", haptic: .medium, action: onPause)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .padding(.bottom, 140)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier(A11yID.autonomosHub)
        // Contain: hero, charter, Retomar/nav lines stay separately focusable.
        .accessibilityElement(children: .contain)
    }

    private var kickerLine: String {
        "\(vestment.kicker) · \(unit.ageLabel)"
    }

    @ViewBuilder
    private var primaryVerb: some View {
        switch vestment {
        case .quiet:
            AutonomosMapChrome.primaryCTA("Retomar", haptic: .medium, action: onResume)
                .accessibilityHint("retoma este Autônomo a partir da pausa")
        case .live:
            EmptyView()
        }
    }

    private enum LocalVestment {
        case live
        case quiet

        var kicker: String {
            switch self {
            case .live: "Vivo"
            case .quiet: "Parado"
            }
        }

        var hero: String {
            switch self {
            case .live: "No escopo"
            case .quiet: "Em pausa"
            }
        }
    }
}
