import SwiftUI
import AtlasCore

// WAVE-156 density peel — MapShell catalog face + self-construction banner

extension AutonomosMapShell {
    /// Catálogo do operador + baseline Nightly/Ritmo (aprender-com-o-uso).
    var catalogFace: some View {
        VStack(spacing: 0) {
            if let receipt = latestMergeProvedReceipt {
                selfConstructionBanner(receipt)
            }
            VStack(alignment: .leading, spacing: 12) {
                AutonomosNightlyProposalBlock(nightly: nightly) { proposal in
                    nightlyStartProposal = proposal
                }
                AutonomosRhythmLearningLine()
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 10)
            .padding(.bottom, 4)

            // WAVE-037: thin fleet strip when global snapshot published (silence if nil).
            if let fleet = model.fleet {
                AutonomosFleetStrip(fleet: fleet, history: model.fleetHistory)
                    .padding(.bottom, 4)
            }

            AutonomosListView(
                units: model.operatorUnits,
                awaitingUnitIDs: AutonomosDecisionJudgment.awaitingUnitIDs(
                    units: model.operatorUnits,
                    backlog: model.backlog,
                    boundUnitID: selectedUnitID
                ),
                onOpen: { unit in
                    selectedUnitID = unit.id
                    destination = .hub
                },
                onCreate: { showNewSheet = true }
            )
        }
    }

    func selfConstructionBanner(_ receipt: SelfConstructionReceipt) -> some View {
        Button {
            selfConstructionReceipt = receipt
        } label: {
            HStack(spacing: 10) {
                Text("✦")
                    .font(AtlasFont.serif(14, .semibold))
                    .foregroundStyle(AtlasTheme.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("O Atlas melhorou o próprio app")
                        .font(AtlasFont.serif(15, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text("Merge comprovado · toque o recibo")
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 14)
            .background(AtlasTheme.surface.opacity(0.55))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AutonomosHubJudgment.selfBuildReceiptSpoken)
    }
}
