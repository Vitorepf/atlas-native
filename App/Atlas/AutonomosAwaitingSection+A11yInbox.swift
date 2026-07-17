import Foundation
import AtlasCore

// Inbox chip spoken — peel de AutonomosAwaitingSection+A11y.

extension AutonomosAwaitingYouSection {
    func inboxSpokenLabel(count: Int) -> String {
        count == 1
            ? "abrir 1 decisão de inbox pendente"
            : "abrir \(count) decisões de inbox pendentes"
    }
}
