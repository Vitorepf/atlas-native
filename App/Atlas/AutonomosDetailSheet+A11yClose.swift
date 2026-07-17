import Foundation
import AtlasCore

/// Close / empty spoken — peel de AutonomosDetailSheet+A11y.
// CloseLabel → AutonomosDetailSheet+A11yCloseLabel.swift
// EmptyLabel → AutonomosDetailSheet+A11yEmptyLabel.swift

extension AutonomosPublicDetailSheet {
    func spokenSheetHint() -> String {
        "lista pública do backlog Autônomos; não afirma execução antes do recibo"
    }
}
