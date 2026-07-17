import Foundation
import AtlasCore

// Close label spoken — peel de AutonomosDetailSheet+A11yClose.

extension AutonomosPublicDetailSheet {
    func spokenCloseLabel() -> String {
        "fechar detalhes de \(kind.title.lowercased())"
    }
}
