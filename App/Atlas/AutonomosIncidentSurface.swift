import SwiftUI
import AtlasCore

// MARK: - Incident / task-health surface (WAVE-036)

/// One domain: published task health → incident/pressure/quiet faces.
struct AutonomosIncidentSurface: View {
    let areaSelected: Bool
    let health: AtlasAutonomosTaskHealthResponse?

    private var face: AutonomosTaskHealthFace {
        AutonomosTaskHealthJudgment.face(areaSelected: areaSelected, health: health)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AutonomosMapChrome.kicker(
                    face.productWord,
                    live: face.productWord == "incident" || face.productWord == "pressure"
                )
                .padding(.bottom, 14)
                AutonomosMapChrome.heroTitle(face.heroTitle, size: 28)
                    .padding(.bottom, 8)
                Text(face.heroSub)
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 22)

                if let health {
                    healthBody(health)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .padding(.bottom, 140)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier(
            face.productWord == "incident"
                ? A11yID.autonomosTaskHealthIncident
                : A11yID.autonomosTaskHealthQuiet
        )
        .accessibilityLabel(face.spokenFace)
    }

    @ViewBuilder
    private func healthBody(_ health: AtlasAutonomosTaskHealthResponse) -> some View {
        AutonomosMapChrome.section("Operação")
            .padding(.bottom, 10)
        Text(AutonomosTaskHealthJudgment.operatingLine(health))
            .font(AtlasFont.serif(16, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 18)

        AutonomosMapChrome.section("Fila")
            .padding(.bottom, 10)
        Text(AutonomosTaskHealthJudgment.tasksSummary(health))
            .font(AtlasFont.mono(12))
            .foregroundStyle(AtlasTheme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 8)
        Text("leases ativos \(health.leases.active)· match claimed \(health.leases.matchesClaimed ? "sim" : "não")")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.bottom, 18)

        let flags = AutonomosTaskHealthJudgment.flagLines(health)
        if !flags.isEmpty {
            AutonomosMapChrome.section("Sinais")
                .padding(.bottom, 10)
            ForEach(Array(flags.enumerated()), id: \.offset) { _, flag in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(AtlasTheme.domOperacional.opacity(0.85))
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)
                    Text(flag)
                        .font(AtlasFont.serif(15))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 10)
                .overlay(alignment: .bottom) { AutonomosMapChrome.hairline }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(AutonomosTaskHealthJudgment.spokenSignal(flag))
            }
        } else if face.productWord == "quiet" {
            Text("Nenhum flag de incidente neste recorte.")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textTertiary)
        }

        Text("observado \(health.observedAt)")
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.top, 20)
            .accessibilityLabel(AutonomosTaskHealthJudgment.spokenObservedAt(health.observedAt))
    }
}
