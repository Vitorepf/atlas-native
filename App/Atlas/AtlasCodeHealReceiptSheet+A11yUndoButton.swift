import Foundation
import AtlasCore

// Undo button spoken — peel de AtlasCodeHealReceiptSheet+A11yUndo.

extension AtlasCodeHealReceiptSheet {
    func spokenUndoButtonLabel() -> String {
        canUndo ? "desfazer cura com recibo" : "desfazer indisponível"
    }

    func spokenUndoButtonHint() -> String {
        canUndo
            ? "envia veto retroativo auditável para esta cura"
            : "prazo de veto encerrado ou recibo sem identificador"
    }
}
