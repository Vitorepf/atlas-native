import Foundation
import AtlasCore

// Decision surface gate — peel de ExecutionProof+ShouldDisplay.

extension ExecutionProof {
    /// Campos publicados pelo ledger — nunca só o rótulo «atlas decide».
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
