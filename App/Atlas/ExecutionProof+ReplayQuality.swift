import SwiftUI
import AtlasCore

// Quality lines — peel de ExecutionProof+ReplayFormat.

extension ExecutionProof {
    func qualityLine(_ q: AtlasQualitySummary) -> String {
        var out = "quality \(String(format: "%.1f", q.score)) · \(q.status)"
        if q.flagCount > 0 { out += " · \(q.flagCount) alertas" }
        if q.actionCount > 0 { out += " · \(q.actionCount) ações" }
        return out
    }

    func qualitySpoken(_ q: AtlasQualitySummary) -> String {
        var parts = ["qualidade \(String(format: "%.1f", q.score)), status \(q.status)"]
        if q.flagCount > 0 { parts.append("\(q.flagCount) alertas") }
        if q.actionCount > 0 { parts.append("\(q.actionCount) ações de correção") }
        return parts.joined(separator: ", ")
    }

    func activitySpoken(_ act: AtlasAgentActivity) -> String {
        var parts = [act.title]
        if let d = act.detail, !d.isEmpty { parts.append(d) }
        return parts.joined(separator: ", ")
    }
}
