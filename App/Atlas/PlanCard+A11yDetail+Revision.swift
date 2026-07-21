import SwiftUI
import AtlasCore

// Revision toggle spoken — peel de PlanCard+A11yDetail.

extension PlanCard {
    func spokenRevisionToggle(expanded: Bool, count: Int) -> String {
        expanded
            ? "comparar versões do plano, expandido, \(count) versões"
            : "comparar versões do plano, \(count) versões"
    }
}
