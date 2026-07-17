import SwiftUI
import AtlasCore

extension ExecutionProof {
    func decideLine(_ d: AtlasDecisionSummary) -> String {
        var out = "atlas decide"
        if let m = d.routeMode { out += " · \(m)" }
        if let p = d.selectedProvider { out += " · \(p)" }
        if let c = d.confidenceScore { out += " · conf \(String(format: "%.2f", c))" }
        if d.wasOverridden { out += " · override" }
        return out
    }

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

    func decisionSpoken(_ d: AtlasDecisionSummary) -> String {
        var parts = ["decisão do atlas"]
        if let m = d.routeMode { parts.append("modo \(m)") }
        if let p = d.selectedProvider { parts.append("provedor \(p)") }
        if let c = d.confidenceScore { parts.append("confiança \(String(format: "%.2f", c))") }
        if d.wasOverridden { parts.append("substituída manualmente") }
        if let r = d.reason, !r.isEmpty { parts.append("motivo \(r)") }
        return parts.joined(separator: ", ")
    }

    func qualityColor(_ q: AtlasQualitySummary) -> Color {
        let status = q.status.lowercased()
        if status.contains("pass") || status.contains("ok") || status.contains("success") {
            return AtlasTheme.domAutonomos
        }
        if status.contains("fail") || status.contains("warn") || status.contains("flag") {
            return AtlasTheme.domOperacional
        }
        return AtlasTheme.textSecondary
    }

    static func hasDecisionSurface(_ d: AtlasDecisionSummary) -> Bool {
        d.selectedProvider != nil
            || d.selectedModel != nil
            || d.reason != nil
            || d.confidenceScore != nil
            || d.riskLevel != nil
            || d.routeMode != nil
            || d.wasOverridden
    }
}
