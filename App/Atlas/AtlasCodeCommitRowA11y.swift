import Foundation
import AtlasCore

// AtlasCodeCommitRow spoken grammar peels (WAVE-054)

enum AtlasCodeCommitRowA11yRowIdentity {
    static func parts(
        node: AtlasCodeGraphNode,
        trunk: String?
    ) -> (title: String, author: String, linha: String) {
        // VoiceOver lidera pelo TIPO (só a palavra, sem escopo — fala limpa) e
        // depois a frase, paridade com o que o olho vê na meta. Sem tipo → só a frase.
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
}

extension AtlasCodeCommitRowA11y {
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

enum AtlasCodeCommitRowA11y {}

extension AtlasCodeCommitRowA11yState {
    static func healedParts(title: String, author: String) -> [String] {
        [title, "por \(author)", "curado"]
    }
}

extension AtlasCodeCommitRowA11yState {
    static func branchPartsHealthy(
        title: String,
        author: String,
        linha: String,
        state: AtlasCodeNodeState
    ) -> [String]? {
        switch state {
        case .healed:
            return healedParts(title: title, author: author)
        case .onMain:
            return onMainParts(title: title, author: author, linha: linha)
        default:
            return nil
        }
    }
}

extension AtlasCodeCommitRowA11yState {
    static func historyParts(title: String, author: String) -> [String] {
        [title, "por \(author)", "história"]
    }
}

extension AtlasCodeCommitRowA11yState {
    static func onMainParts(title: String, author: String, linha: String) -> [String] {
        [title, "por \(author)", "na \(linha)"]
    }
}

extension AtlasCodeCommitRowA11yState {
    static func branchParts(
        title: String,
        author: String,
        linha: String,
        state: AtlasCodeNodeState
    ) -> [String] {
        if let healthy = branchPartsHealthy(title: title, author: author, linha: linha, state: state) {
            return healthy
        }
        switch state {
        case .history:
            return historyParts(title: title, author: author)
        case .violating:
            return []
        default:
            return []
        }
    }
}

extension AtlasCodeCommitRowA11y {
    static func spokenCommitTail(authoredAt: Int, isDimmed: Bool) -> [String] {
        var parts: [String] = []
        let when = AtlasCodeRelativeTime.short(from: authoredAt)
        if !when.isEmpty { parts.append("há \(when)") }
        if isDimmed { parts.append("fora da resposta") }
        return parts
    }
}

enum AtlasCodeCommitRowA11yState {
    static func stateParts(
        title: String,
        author: String,
        linha: String,
        state: AtlasCodeNodeState,
        ruleId: String?,
        trunk: String?
    ) -> [String] {
        switch state {
        case .violating:
            return violatingParts(
                title: title,
                author: author,
                linha: linha,
                ruleId: ruleId,
                trunk: trunk
            )
        default:
            return branchParts(title: title, author: author, linha: linha, state: state)
        }
    }
}

extension AtlasCodeCommitRowA11yState {
    static func violatingParts(
        title: String,
        author: String,
        linha: String,
        ruleId: String?,
        trunk: String?
    ) -> [String] {
        var parts = [title, "por \(author)", "fora da \(linha)"]
        if let ruleId { parts.append(AtlasCodeIssue.law(ruleId, trunk: trunk)) }
        return parts
    }
}
