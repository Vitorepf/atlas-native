import Foundation
import AtlasCore

// Counts — peel de AutonomosPublicDetailSheet a11y.
// Work → AutonomosDetailSheet+A11yCount+Work.swift

extension AutonomosPublicDetailSheet {
    static func publicItemCount(kind: AutonomosDetailSheet, backlog: AtlasAutonomosBacklogResponse) -> Int {
        if let work = publicWorkCount(kind: kind, backlog: backlog) { return work }
        switch kind {
        case .findings: return backlog.findings.items.count
        case .budgets: return 1
        default: return 0
        }
    }
}
