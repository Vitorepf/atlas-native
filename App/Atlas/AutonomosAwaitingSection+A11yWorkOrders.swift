import Foundation
import AtlasCore

// Work orders chip spoken — peel de AutonomosAwaitingSection+A11y.

extension AutonomosAwaitingYouSection {
    func workOrdersSpokenLabel(count: Int) -> String {
        count == 1
            ? "abrir 1 ordem aguardando sua decisão"
            : "abrir \(count) ordens aguardando sua decisão"
    }
}
