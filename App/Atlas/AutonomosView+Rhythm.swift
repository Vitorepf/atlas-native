import SwiftUI
import AtlasCore

// Ritmo e helpers de reversão — peel de AutonomosView.

extension AutonomosView {
    func refreshRhythmLearning() async {
        let windows = await AtlasSession.rhythm.windows(minimumDays: 4)
        rhythmSampleDays = windows.sampleDays
    }

    func oldestBacklogCreatedAt() -> Date? {
        guard let backlog = model.backlog else { return nil }
        let values = backlog.workOrders.compactMap { AtlasTime.date($0.createdAt) }
            + backlog.inboxItems.compactMap { AtlasTime.date($0.createdAt) }
            + backlog.findings.items.compactMap { AtlasTime.date($0.createdAt) }
        return values.min()
    }

    func canRevertSelfConstruction(_ receipt: SelfConstructionReceipt) -> Bool {
        model.canControlSelectedArea && receipt.cycle.mergeHash.nonEmpty != nil
    }

    func revertReceipt(for receipt: SelfConstructionReceipt) -> AtlasAutonomosCycleRevertResponse? {
        guard let revert = model.lastRevertReceipt else { return nil }
        guard revert.revertOf.cycleIndex == receipt.cycle.cycleIndex,
              revert.revertOf.mergeHash == receipt.cycle.mergeHash else { return nil }
        return revert
    }
}
