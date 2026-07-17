import Foundation

// Submit hint spoken — peel de SteerInteractionSheet+A11ySubmit.

extension SteerInteractionSheet {
    func spokenSubmitHint(canSubmit: Bool) -> String {
        canSubmit
            ? "envia a instrução ao Atlas no escopo selecionado"
            : "escreva o que muda a partir daqui"
    }
}
