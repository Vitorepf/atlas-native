import SwiftUI
import AtlasCore

// Replay spoken metrics — peel de ExecutionProof+ReplaySpokenCollapse.

extension ExecutionProof {
    func spokenCollapsedMetricsParts() -> [String] {
        var parts: [String] = []
        if !bubble.activities.isEmpty { parts.append("\(bubble.activities.count) passos") }
        if let ms = bubble.elapsedMs, ms > 0 { parts.append(humanDuration(ms)) }
        if bubble.decisionSummary.map(Self.hasDecisionSurface) == true { parts.append("decisão do atlas") }
        if bubble.qualitySummary != nil { parts.append("avaliação de qualidade") }
        if !artifactItems.isEmpty { parts.append("\(artifactItems.count) artefatos") }
        return parts
    }
}
