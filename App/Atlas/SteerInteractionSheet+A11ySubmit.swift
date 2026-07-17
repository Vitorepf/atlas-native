import Foundation
import AtlasCore

// Submit spoken labels — peel de SteerInteractionSheet+A11y.
// Hint → SteerInteractionSheet+A11ySheetHint.swift
// SubmitHint → SteerInteractionSheet+A11ySubmitHint.swift

extension SteerInteractionSheet {
    func spokenSubmitLabel(canSubmit: Bool) -> String {
        canSubmit ? "enviar instrução de redirecionamento" : "enviar indisponível, instrução vazia"
    }
}
