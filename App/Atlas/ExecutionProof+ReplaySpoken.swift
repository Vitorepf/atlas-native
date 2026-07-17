import SwiftUI
import AtlasCore

// Decision spoken — peel de ExecutionProof+ReplayFormat.
// Quality → ExecutionProof+ReplayQuality.swift
// Route → ExecutionProof+ReplaySpoken+Route.swift

extension ExecutionProof {
    func decisionSpoken(_ d: AtlasDecisionSummary) -> String {
        var parts = decisionSpokenRoute(d)
        if let c = d.confidenceScore { parts.append("confiança \(String(format: "%.2f", c))") }
        if d.wasOverridden { parts.append("substituída manualmente") }
        if let r = d.reason, !r.isEmpty { parts.append("motivo \(r)") }
        return parts.joined(separator: ", ")
    }
}
