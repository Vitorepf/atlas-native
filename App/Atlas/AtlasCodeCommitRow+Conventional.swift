import Foundation

// Convenção do commit — peel presentation-only de AtlasCodeCommitRow.
// O TIPO (feat/fix/polish…) é sinal alto por linha; o autor é quase-constante
// num repo de um operador. Então a manchete é a FRASE e a meta lidera pelo tipo.

extension AtlasCodeCommitRow {
    /// Manchete: mensagem completa (tipo vive aqui). Sem mensagem → hash.
    var titleText: String {
        guard let message = node.message, !message.isEmpty else {
            return String(node.hash.prefix(8))
        }
        return message
    }
}
