import Foundation
import AtlasCore

// Branch · autor — presentation-only. Sem inventar nome: tip de `refs` ou
// trunk por alcançabilidade (onMain/healed). Lei do operador: meta sempre
// `branch · autor · tempo`.

extension AtlasCodeCommitRow {
    /// Nome de branch publicado no tip, se o git decorou este nó.
    static func tipBranch(from refs: [String], excluding: String?) -> String? {
        for ref in refs {
            let name = ref
                .replacingOccurrences(of: "HEAD -> ", with: "")
                .replacingOccurrences(of: "origin/", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if name.isEmpty || name == "HEAD" { continue }
            if let excluding, name == excluding { continue }
            return name
        }
        return nil
    }

    var displayBranch: String {
        if let tip = Self.tipBranch(from: node.refs, excluding: trunk) {
            return tip
        }
        if let tip = Self.tipBranch(from: node.refs, excluding: nil) {
            return tip
        }
        if state == .onMain || state == .healed {
            return trunk ?? "main"
        }
        return trunk ?? "—"
    }

    var displayAuthor: String {
        if !node.authorName.isEmpty { return node.authorName }
        if !node.authorEmail.isEmpty { return node.authorEmail }
        return "—"
    }
}
