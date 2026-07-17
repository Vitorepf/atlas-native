import SwiftUI
import AtlasCore

// Open button action — peel de AutonomosAreaDeliveredSection+RowGraph+OpenButton.

extension AutonomosAreaDeliveredSection {
    func deliveredGraphOpenAction(cycle: AtlasAutonomosCycle, repo: String) -> () -> Void {
        { openCommit(cycle.mergeHash, repo: repo) }
    }
}
