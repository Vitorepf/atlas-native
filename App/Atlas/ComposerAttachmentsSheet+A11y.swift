import Foundation

/// Spoken labels — peel de ComposerAttachmentsSheet (CICLO C residual honesty).
/// Colar só quando há texto real na área de transferência; câmera reusa CameraPickerA11y.

enum ComposerAttachmentsA11y {
    static let spokenSheet = "adicionar anexo à mensagem"
    static let spokenSheetHint = "foto, câmera, arquivo ou texto colado no próximo envio"

    static let spokenPhoto = "escolher foto da biblioteca"
    static let spokenPhotoHint = "abre a biblioteca de fotos; nada é anexado até escolher"

    static let spokenFile = "escolher arquivo"
    static let spokenFileHint = "PDF, texto, código ou dados do dispositivo"

    static func spokenPaste(hasText: Bool) -> String {
        hasText
            ? "colar contexto da área de transferência"
            : "colar indisponível, área de transferência vazia"
    }

    static let spokenPasteHint = "adiciona o texto copiado como contexto da mensagem"
    static let spokenPasteDisabledHint = "copie texto antes de colar como contexto"
}
