import Foundation
import AtlasCore
import SwiftUI

// MARK: - Types

/// Exclusive commit-row face (WAVE-054). Dim elevates over node state.
enum AtlasCodeCommitRowFace: Equatable {
    case dimmed
    case violating
    case healed
    case onMain
    case history

    var productWord: String {
        switch self {
        case .dimmed: return "dimmed"
        case .violating: return "fora"
        case .healed: return "curados"
        case .onMain: return "main"
        case .history: return "história"
        }
    }

    var spokenFace: String {
        switch self {
        case .dimmed: return "fora da resposta da pílula"
        case .violating: return "fora da linha"
        case .healed: return "curado"
        case .onMain: return "na linha principal"
        case .history: return "história"
        }
    }
}

// MARK: - Judgment

/// Pure commit-row grammar — face · tip branch · meta color · pack helpers.
enum AtlasCodeCommitRowJudgment {

    static func face(
        state: AtlasCodeNodeState,
        isDimmed: Bool
    ) -> AtlasCodeCommitRowFace {
        if isDimmed { return .dimmed }
        switch state {
        case .violating: return .violating
        case .healed: return .healed
        case .onMain: return .onMain
        case .history: return .history
        }
    }

    /// Align non-dim product words with graph judgment vocabulary.
    static func productWord(
        state: AtlasCodeNodeState,
        isDimmed: Bool
    ) -> String {
        face(state: state, isDimmed: isDimmed).productWord
    }

    static func branchMetaColor(for state: AtlasCodeNodeState) -> Color {
        switch state {
        case .violating: return AtlasCodePalette.alert
        case .onMain, .healed: return AtlasTheme.accent
        case .history: return AtlasTheme.prussian
        }
    }

    /// Branch tip published on node refs; pure parse (no invent).
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

    static func displayBranch(
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        trunk: String?
    ) -> String {
        if let tip = tipBranch(from: node.refs, excluding: trunk) {
            return tip
        }
        if let tip = tipBranch(from: node.refs, excluding: nil) {
            return tip
        }
        if state == .onMain || state == .healed {
            return trunk ?? "main"
        }
        return trunk ?? "—"
    }

    static func displayAuthor(node: AtlasCodeGraphNode) -> String {
        if !node.authorName.isEmpty { return node.authorName }
        if !node.authorEmail.isEmpty { return node.authorEmail }
        return "—"
    }

    static func packFacts(
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        isDimmed: Bool,
        trunk: String?,
        ruleId: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(state: state, isDimmed: isDimmed)
        facts.append("commit_row_face: \(face.productWord)")
        facts.append("commit: \(String(node.hash.prefix(7)))")
        facts.append("branch: \(displayBranch(node: node, state: state, trunk: trunk))")
        if let message = node.message, !message.isEmpty {
            let snip = message.count <= 72 ? message : String(message.prefix(71)) + "…"
            facts.append("subject: \(snip)")
        } else {
            absences.append("mensagem de commit ausente")
        }
        if let ruleId {
            facts.append("rule: \(ruleId)")
        }
        if isDimmed {
            facts.append("dimmed: true")
        }
        return (facts, absences)
    }
}
