import Foundation
import AtlasCore

// Row identity — peel de AtlasCodeCommitRow+A11y.

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
