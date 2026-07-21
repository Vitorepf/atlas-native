import Foundation
import AtlasCore
import SwiftUI

// WAVE-145

extension PlanJudgment {
    // MARK: Card chrome spoken (WAVE-105)

    static func spokenChipRow(label: String, items: [String]) -> String {
        "\(label), \(items.count) itens, \(items.joined(separator: ", "))"
    }

    static func spokenPlanDetail(_ plan: AtlasExecutionPlan) -> String {
        var parts: [String] = []
        if !plan.agents.isEmpty {
            parts.append("agentes, \(plan.agents.map(\.title).joined(separator: ", "))")
        }
        if !plan.tools.isEmpty {
            parts.append("ferramentas, \(plan.tools.map(\.label).joined(separator: ", "))")
        }
        if !plan.qualityGates.isEmpty {
            parts.append("gates, \(plan.qualityGates.map(\.label).joined(separator: ", "))")
        }
        return parts.joined(separator: ", ")
    }

    static func spokenRevisionToggle(expanded: Bool, count: Int) -> String {
        expanded
            ? "comparar versões do plano, expandido, \(count) versões"
            : "comparar versões do plano, \(count) versões"
    }

    static func spokenDetailToggle(showDetail: Bool) -> String {
        showDetail
            ? "ocultar ferramentas agentes e gates"
            : "mostrar ferramentas agentes e gates"
    }

    // MARK: Pack

    static func packFacts(
        plan: AtlasExecutionPlan?,
        progress: AtlasExecutionPlan.Progress?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(plan: plan, progress: progress)
        facts.append("plan_face: \(face.productWord)")
        guard let plan, !plan.steps.isEmpty else {
            absences.append("plano de execução não publicado neste recorte")
            return (facts, absences)
        }
        facts.append("plan_title: \(plan.title)")
        facts.append("plan_steps: \(plan.steps.count)")
        facts.append(summaryLine(plan: plan, progress: progress))
        if let progress {
            facts.append("progress_current: \(progress.current)")
            facts.append("progress_total: \(progress.total)")
            facts.append("progress_title: \(progress.title)")
            facts.append("progress_terminal: \(progress.isTerminal)")
        } else {
            absences.append("nenhum checkpoint de progresso observado")
        }
        if !plan.agents.isEmpty {
            facts.append("agents: " + plan.agents.map(\.title).joined(separator: ", "))
        } else {
            absences.append("sem agentes no plano publicado")
        }
        if !plan.tools.isEmpty {
            facts.append("tools: " + plan.tools.map(\.label).joined(separator: ", "))
        }
        if !plan.qualityGates.isEmpty {
            facts.append("gates: " + plan.qualityGates.map(\.label).joined(separator: ", "))
        }
        return (facts, absences)
    }

}
