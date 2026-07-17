import Foundation
import AtlasCore

// Submit spoken labels — peel de SteerInteractionSheet+A11y.

extension SteerInteractionSheet {
    func spokenSubmitLabel(canSubmit: Bool) -> String {
        canSubmit ? "enviar instrução de redirecionamento" : "enviar indisponível, instrução vazia"
    }

    func spokenSubmitHint(canSubmit: Bool) -> String {
        canSubmit
            ? "envia a instrução ao Atlas no escopo selecionado"
            : "escreva o que muda a partir daqui"
    }

    func spokenSheetHint() -> String {
        "instrução entra no próximo checkpoint seguro; o Atlas pode recusar"
    }
}
