import AtlasCore
import Foundation

// Cycle 040 fuse → ChangeReviewCouncilRow+A11y.swift

/// Só fala o que `council_review` publica; sem `agentVerdicts` nem papéis inventados.

extension AtlasTraceGovernance.CouncilMember {
    var spokenCouncilLine: String {
        var parts = [provider]
        if let model = model { parts.append(model) }
        parts.append("status \(status)")
        if let hash = responseHash {
            parts.append("hash de resposta \(String(hash.prefix(12)))")
        }
        if let code = errorCode { parts.append("código \(code)") }
        if let latency = latencyMs { parts.append("\(latency) milissegundos") }
        return parts.joined(separator: ", ")
    }
}
