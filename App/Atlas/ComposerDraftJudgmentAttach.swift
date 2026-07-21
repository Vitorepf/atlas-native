import Foundation
import AtlasCore
import SwiftUI

// WAVE-147

extension ComposerDraftJudgment {
    // MARK: Attach sheet spoken (IDLE · was ComposerAttachmentsA11y)

    static let spokenAttachSheet = "adicionar anexo à mensagem"
    static let spokenAttachSheetHint =
        "foto, câmera, arquivo ou texto colado no próximo envio"
    static let spokenPhoto = "escolher foto da biblioteca"
    static let spokenPhotoHint =
        "abre a biblioteca de fotos; nada é anexado até escolher"
    static let spokenFile = "escolher arquivo"
    static let spokenFileHint = "PDF, texto, código ou dados do dispositivo"
    static let spokenPasteHint = "adiciona o texto copiado como contexto da mensagem"
    static let spokenPasteDisabledHint = "copie texto antes de colar como contexto"

    static func spokenPaste(hasText: Bool) -> String {
        hasText
            ? "colar contexto da área de transferência"
            : "colar indisponível, área de transferência vazia"
    }

    // MARK: Camera attach spoken (IDLE · was CameraPickerA11y)

    static let spokenCameraSurface = "câmera para anexar foto"
    static let spokenCameraHint =
        "confirme a captura para anexar; cancelar não adiciona nada"
    static let captureFailedToast = "não consegui capturar a foto"
    static let spokenChooseCamera = "capturar foto na câmera"
    static let spokenChooseCameraHint =
        "abre a câmera; nada é anexado até confirmar a captura"

    // MARK: Attachment row spoken (IDLE)

    static func spokenAttachmentRow(title: String, subtitle: String) -> String {
        "\(title), \(subtitle)"
    }


}
