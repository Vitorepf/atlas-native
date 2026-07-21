import SwiftUI

/// Evolução — timeline deste Autônomo. Sem motor vinculado = ausência honesta.
struct AutonomosEvolutionView: View {
    let unit: AutonomosUnit?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AutonomosMapChrome.kicker("Evolução", live: unit?.paused == false)
                    .padding(.bottom, 14)
                if let unit {
                    Text(unit.ageLabel)
                        .font(AtlasFont.mono(28, .semibold))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .monospacedDigit()
                        .padding(.bottom, 8)
                    Text(unit.charter)
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .padding(.bottom, 28)
                }

                AutonomosMapChrome.section("Marcos")
                    .padding(.bottom, 12)

                Text("Ainda sem prova publicada neste Autônomo.")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Quando o Server aceitar create, os ciclos aparecem aqui — só deste escopo.")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.top, 10)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .padding(.bottom, 140)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier(A11yID.autonomosEvolution)
    }
}
