import SwiftUI
import AtlasCore

// Progress badge spoken — peel de PlanCard+A11y.

extension PlanCard {
    func spokenProgressBadge(_ progress: AtlasExecutionPlan.Progress) -> String {
        "\(progress.current) de \(progress.total) passos, \(progress.title)"
    }
}
