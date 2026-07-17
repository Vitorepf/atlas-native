import Foundation
import AtlasCore

/// Spoken labels da linha de commit — peel de AtlasCodeCommitRow (CICLO C).
/// Trunk/lei só quando publicados; tempo relativo honesto; dimmed explícito.

enum AtlasCodeCommitRowA11y {
    static func spokenCommitRow(
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        trunk: String?,
        ruleId: String?,
        isDimmed: Bool
    ) -> String {
        let title = node.message ?? String(node.hash.prefix(8))
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        let linha = trunk?.nonEmpty ?? "linha principal"
        var parts: [String]
        switch state {
        case .violating:
            parts = [title, "por \(author)", "fora da \(linha)"]
            if let ruleId { parts.append(AtlasCodeIssue.law(ruleId, trunk: trunk)) }
        case .healed:
            parts = [title, "por \(author)", "curado"]
        case .onMain:
            parts = [title, "por \(author)", "na \(linha)"]
        case .history:
            parts = [title, "por \(author)", "história"]
        }
        let when = AtlasCodeRelativeTime.short(from: node.authoredAt)
        if !when.isEmpty { parts.append("há \(when)") }
        if isDimmed { parts.append("fora da resposta") }
        return parts.joined(separator: ", ")
    }
}
