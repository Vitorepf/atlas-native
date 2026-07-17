import Foundation

// Paste spoken — peel de ComposerAttachmentsSheet+A11y.

extension ComposerAttachmentsA11y {
    static func spokenPaste(hasText: Bool) -> String {
        hasText
            ? "colar contexto da área de transferência"
            : "colar indisponível, área de transferência vazia"
    }

    static let spokenPasteHint = "adiciona o texto copiado como contexto da mensagem"
    static let spokenPasteDisabledHint = "copie texto antes de colar como contexto"
}
