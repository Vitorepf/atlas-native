import SwiftUI
import AtlasCore

// Quality color / decision surface — peel de ExecutionProof+ReplaySpoken.

extension ExecutionProof {
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
