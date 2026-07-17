import Foundation
import AtlasCore

/// Spoken labels do conselho — peel de ChangeReviewCouncilMemberRow (cena 07).
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

enum ChangeReviewCouncilA11y {
    static func spokenSection(memberCount: Int, diverged: Bool) -> String {
        var parts = ["conselho, \(memberCount) \(memberCount == 1 ? "membro" : "membros")"]
        if diverged { parts.append("divergência entre pareceres") }
        return parts.joined(separator: ", ")
    }
}
