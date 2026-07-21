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

    // MARK: Spoken row (IDLE · was AtlasCodeCommitRowA11y)

    static func spokenCommitRow(
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        trunk: String?,
        ruleId: String?,
        isDimmed: Bool
    ) -> String {
        let identity = spokenIdentity(node: node, trunk: trunk)
        var parts = spokenStateParts(
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

    static func spokenIdentity(
        node: AtlasCodeGraphNode,
        trunk: String?
    ) -> (title: String, author: String, linha: String) {
        // VoiceOver lidera pelo TIPO (só a palavra) e depois a frase.
        let title: String
        if let message = node.message {
            let parsed = AtlasConventionalCommit.split(message)
            let typeWord = parsed.type.map { String($0.prefix { $0.isLetter }) }
            title = typeWord.map { "\($0), \(parsed.subject)" } ?? parsed.subject
        } else {
            title = String(node.hash.prefix(8))
        }
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        let linha = trunk?.nonEmpty ?? "linha principal"
        return (title, author, linha)
    }

    static func spokenCommitTail(authoredAt: Int, isDimmed: Bool) -> [String] {
        var parts: [String] = []
        let when = AtlasCodeRelativeTime.short(from: authoredAt)
        if !when.isEmpty { parts.append("há \(when)") }
        if isDimmed { parts.append("fora da resposta") }
        return parts
    }

    static func spokenStateParts(
        title: String,
        author: String,
        linha: String,
        state: AtlasCodeNodeState,
        ruleId: String?,
        trunk: String?
    ) -> [String] {
        switch state {
        case .violating:
            var parts = [title, "por \(author)", "fora da \(linha)"]
            if let ruleId { parts.append(AtlasCodeIssue.law(ruleId, trunk: trunk)) }
            return parts
        case .healed:
            return [title, "por \(author)", "curado"]
        case .onMain:
            return [title, "por \(author)", "na \(linha)"]
        case .history:
            return [title, "por \(author)", "história"]
        }
    }
}
