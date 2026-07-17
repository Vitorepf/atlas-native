import SwiftUI
import AtlasCore

// Decision/quality spoken — peel de ExecutionProof+ReplayFormat.

extension ExecutionProof {
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
