import Foundation
import AtlasCore

/// Remove / failed hints — peel de DraftThumb+A11y.

enum DraftThumbA11yHints {
    static let removeHint = "remove este anexo antes do envio"
    static let failedHint = "toque para ver o erro completo no aviso"

    static func spokenFailedValue(_ message: String) -> String {
        message.isEmpty ? "erro no envio" : message
    }

    static func spokenRemove(_ draft: LocalDraft) -> String {
        "remover anexo \(draft.fileName)"
    }
}
