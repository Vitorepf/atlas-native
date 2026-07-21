import SwiftUI
import AtlasCore

// Plan detail spoken — peel de PlanCard+A11yDetail.

extension PlanCard {
    func spokenPlanDetail(_ plan: AtlasExecutionPlan) -> String {
        var parts: [String] = []
        if !plan.agents.isEmpty { parts.append("agentes, \(plan.agents.map(\.title).joined(separator: ", "))") }
        if !plan.tools.isEmpty { parts.append("ferramentas, \(plan.tools.map(\.label).joined(separator: ", "))") }
        if !plan.qualityGates.isEmpty { parts.append("gates, \(plan.qualityGates.map(\.label).joined(separator: ", "))") }
        return parts.joined(separator: ", ")
    }
}
