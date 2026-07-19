import Foundation

// Convenção do commit — peel presentation-only de AtlasCodeCommitRow.
// O TIPO (feat/fix/polish…) é sinal alto por linha; o autor é quase-constante
// num repo de um operador. Então a manchete é a FRASE e a meta lidera pelo tipo.

extension AtlasCodeCommitRow {
    /// Manchete: a frase do commit, sem o prefixo de tipo. Sem mensagem → hash.
    var titleText: String {
        guard let message = node.message else { return String(node.hash.prefix(8)) }
        return AtlasConventionalCommit.split(message).subject
    }

    /// Token que lidera a meta: o TIPO quando convencional, senão o autor.
    var metaLead: String {
        if let message = node.message,
           let type = AtlasConventionalCommit.split(message).type {
            return type
        }
        return node.authorName.isEmpty ? node.authorEmail : node.authorName
    }
}
