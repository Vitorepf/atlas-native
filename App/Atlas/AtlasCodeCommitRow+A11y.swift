import Foundation
import AtlasCore

/// Spoken labels da linha de commit — peel de AtlasCodeCommitRow (CICLO C).
/// Trunk/lei só quando publicados; tempo relativo honesto; dimmed explícito.
/// State → AtlasCodeCommitRow+A11yState.swift
/// Tail → AtlasCodeCommitRow+A11yCommitTail.swift
/// Identity → AtlasCodeCommitRow+A11y+RowIdentity.swift

enum AtlasCodeCommitRowA11y {
    static func spokenCommitRow(
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        trunk: String?,
        ruleId: String?,
        isDimmed: Bool
    ) -> String {
        let identity = AtlasCodeCommitRowA11yRowIdentity.parts(node: node, trunk: trunk)
        var parts = AtlasCodeCommitRowA11yState.stateParts(
            title: identity.title,
            author: identity.author,
            linha: identity.linha,
            state: state,
            ruleId: ruleId,
            trunk: trunk
        )
        parts.append(contentsOf: spokenCommitTail(authoredAt: node.authoredAt, isDimmed: isDimmed))
        return parts.joined(separator: ", ")
    }
}
