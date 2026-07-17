import Foundation
import AtlasCore

/// Close / empty spoken — peel de AutonomosDetailSheet+A11y.

extension AutonomosPublicDetailSheet {
    func spokenSheetHint() -> String {
        "lista pública do backlog Autônomos; não afirma execução antes do recibo"
    }

    func spokenCloseLabel() -> String {
        "fechar detalhes de \(kind.title.lowercased())"
    }

    func spokenEmptyLabel() -> String {
        "sem projeção pública disponível agora"
    }
}
