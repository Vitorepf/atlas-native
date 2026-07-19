import Foundation
import AtlasCore

// Row identity — peel de AtlasCodeCommitRow+A11y.

enum AtlasCodeCommitRowA11yRowIdentity {
    static func parts(
        node: AtlasCodeGraphNode,
        trunk: String?
    ) -> (title: String, author: String, linha: String) {
        // VoiceOver lê a FRASE limpa (sem o prefixo de tipo), igual à manchete.
        let title = node.message.map { AtlasConventionalCommit.split($0).subject }
            ?? String(node.hash.prefix(8))
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        let linha = trunk?.nonEmpty ?? "linha principal"
        return (title, author, linha)
    }
}
