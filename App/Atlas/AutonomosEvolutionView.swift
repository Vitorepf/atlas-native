import SwiftUI
import AtlasCore

/// Evolução — marcos publicados deste Autônomo (WAVE-034). Zero inventar entregas.
struct AutonomosEvolutionView: View {
    let unit: AutonomosUnit?
    let areaSelected: Bool
    let delivered: AtlasAutonomosDeliveredResponse?
    let cycles: AtlasAutonomosCyclesResponse?
    let onOpenReceipt: (SelfConstructionReceipt) -> Void

    private var marcos: [AutonomosEvolutionMarco] {
        AutonomosEvolutionJudgment.marcos(delivered: delivered, cycles: cycles)
    }

    private var face: AutonomosEvolutionFace {
        AutonomosEvolutionJudgment.face(areaSelected: areaSelected, marcos: marcos)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AutonomosMapChrome.kicker("Evolução", live: face.productWord == "delivered")
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
                        .padding(.bottom, 20)
                }

                Text(face.spokenFace)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.bottom, 8)
                Text(face.heroSub)
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 24)

                switch face {
                case .unbound, .empty:
                    emptyBlock
                case .items:
                    AutonomosMapChrome.section("Marcos")
                        .padding(.bottom, 12)
                    ForEach(marcos) { marco in
                        marcoRow(marco)
                    }
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .padding(.bottom, 140)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier(A11yID.autonomosEvolution)
        .accessibilityLabel(face.spokenFace)
    }

    private var emptyBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            AutonomosMapChrome.section("Marcos")
            Text(face.heroSub)
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func marcoRow(_ marco: AutonomosEvolutionMarco) -> some View {
        Button {
            guard marco.mergeProved else { return }
            onOpenReceipt(SelfConstructionReceipt(cycle: marco.cycle, finding: nil))
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(marco.title)
                        .font(AtlasFont.serif(17, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(marco.meta)
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if marco.mergeProved {
                    Image(systemName: "chevron.right")
                        .atlasSans(12, .semibold)
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .padding(.top, 4)
                }
            }
            .padding(.vertical, 16)
            .opacity(marco.mergeProved ? 1 : 0.72)
        }
        .buttonStyle(.plain)
        .disabled(!marco.mergeProved)
        .overlay(alignment: .bottom) { AutonomosMapChrome.hairline }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(marco.title), \(marco.meta)")
        .accessibilityHint(marco.mergeProved ? "abre o recibo de auto-construção" : "")
    }
}
