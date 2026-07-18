import SwiftUI
import AtlasCore

// Idade do backlog — peel de AutonomosView. (A linha de ritmo é
// autossuficiente em AutonomosAwaitingSection+Rhythm.swift.)
// Revert → AutonomosView+Revert.swift

extension AutonomosView {
    func oldestBacklogCreatedAt() -> Date? {
        guard let backlog = model.backlog else { return nil }
        let values = backlog.workOrders.compactMap { AtlasTime.date($0.createdAt) }
            + backlog.inboxItems.compactMap { AtlasTime.date($0.createdAt) }
            + backlog.findings.items.compactMap { AtlasTime.date($0.createdAt) }
        return values.min()
    }
}
