import SwiftUI
import AtlasCore

// Contagens — peel de AutonomosAreaDetailSection.

extension AutonomosAreaDetailSection {
    var cyclesCount: Int? { model.cycles?.ledgerRecordCountTotal }
    var workOrderCount: Int? { model.backlog?.workOrders.count }
    var inboxCount: Int? { model.backlog?.inboxItems.count }
}
