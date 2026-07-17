import SwiftUI
import AtlasCore

/// Spoken labels do grafo — peel de AtlasCodeView+Graph (CICLO C residual honesty).

enum AtlasCodeGraphA11y {
    static func spokenStatus(scanState: AtlasCodeScanState, headline: String) -> String {
        switch scanState {
        case .clean, .unknown:
            return headline
        case .violating:
            return "atenção, \(headline)"
        }
    }

    static func spokenFilterChip(
        _ option: AtlasCodeGraphStateFilter,
        count: Int,
        active: Bool,
        silent: Bool
    ) -> String {
        var label = "filtrar grafo por \(option.label), \(count) commits"
        if active { label += ", selecionado" }
        if silent { label += ", nenhum commit neste filtro" }
        return label
    }

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
        if isDimmed { parts.append("fora da resposta") }
        return parts.joined(separator: ", ")
    }

    static let emptyGraph = "grafo sem commits nesta janela"
}
