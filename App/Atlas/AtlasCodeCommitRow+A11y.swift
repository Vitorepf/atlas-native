import Foundation
import AtlasCore

/// Spoken labels da linha de commit — peel de AtlasCodeCommitRow (CICLO C).
/// Trunk/lei só quando publicados; tempo relativo honesto; dimmed explícito.
/// State → AtlasCodeCommitRow+A11yState.swift

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
        var parts = AtlasCodeCommitRowA11yState.stateParts(
            title: title, author: author, linha: linha, state: state, ruleId: ruleId, trunk: trunk
        )
        let when = AtlasCodeRelativeTime.short(from: node.authoredAt)
        if !when.isEmpty { parts.append("há \(when)") }
        if isDimmed { parts.append("fora da resposta") }
        return parts.joined(separator: ", ")
    }
}
