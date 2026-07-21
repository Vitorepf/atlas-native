import SwiftUI
import AtlasCore

// IDLE-COMPRESS peel routes from AutonomosMapShell (canon §7 · density ≤400)

extension AutonomosMapShell {
    @ViewBuilder
    func route(_ destination: AutonomosDestination) -> some View {
        switch destination {
        case .hub:
            if let unit = selectedUnit {
                AutonomosHubView(
                    unit: unit,
                    vestment: organismVestment,
                    controlFace: controlFace,
                    controlReceiptLine: controlReceiptLine,
                    evolutionMeta: AutonomosEvolutionJudgment.hubEvolutionMeta(
                        marcos: AutonomosEvolutionJudgment.marcos(
                            delivered: model.delivered,
                            cycles: model.cycles
                        ),
                        areaSelected: model.selectedArea != nil
                    ),
                    canTransfer: AutonomosTransferJudgment.canTransfer(
                        canControlSelectedArea: model.canControlSelectedArea
                    ),
                    transferReceiptLine: AutonomosTransferJudgment.receiptLine(model.lastTransferReceipt)
                        ?? model.controlError,
                    incidentMeta: AutonomosTaskHealthJudgment.hubIncidentMeta(health: model.taskHealth),
                    digestMeta: AutonomosDigestJudgment.hubMeta(from: model.digest),
                    needsAreaBind: areaBindFace.needsChooser,
                    registeredAreaCount: AutonomosAreaBindJudgment.registeredAreas(model.areas).count,
                    onChooseArea: { showAreaBindChooser = true },
                    onNavigate: { self.destination = $0 },
                    onControl: { pendingRunControl = $0 },
                    onTransfer: { showTransferSheet = true },
                    onLocalCatalogPause: { model.setOperatorUnitPaused(id: unit.id, paused: true) },
                    onLocalCatalogResume: { model.setOperatorUnitPaused(id: unit.id, paused: false) },
                    onEnd: { confirmEnd = true }
                )
            } else {
                missingUnit
            }
        case .evolution:
            AutonomosEvolutionView(
                unit: selectedUnit,
                areaSelected: model.selectedArea != nil,
                delivered: model.delivered,
                cycles: model.cycles,
                onOpenReceipt: { selfConstructionReceipt = $0 }
            )
        case .decisions, .decisionInbox, .decisionOrder:
            // WAVE-026: published backlog → decision surface; silence if empty.
            AutonomosDecisionSurface(
                model: model,
                destination: destination,
                onNavigate: { self.destination = $0 }
            )
        case .incident:
            // WAVE-036: task health → incident surface (published flags only).
            AutonomosIncidentSurface(
                areaSelected: model.selectedArea != nil,
                health: model.taskHealth
            )
        case .moment:
            // WAVE-038: scheduled digest window (provider-safe) — not invent.
            AutonomosDigestSurface(digest: model.digest)
        }
    }

    var missingUnit: some View {
        VStack(alignment: .leading, spacing: 12) {
            AutonomosMapChrome.heroTitle("Autônomo ausente", size: 26)
            Text("Volte à lista e abra de novo.")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .padding(AtlasTheme.Space.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    func deleteSelected() {
        guard let id = selectedUnitID else { return }
        model.removeOperatorUnit(id: id)
        selectedUnitID = nil
        destination = nil
    }
}
