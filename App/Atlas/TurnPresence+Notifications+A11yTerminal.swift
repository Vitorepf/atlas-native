import Foundation
import AtlasCore

/// Terminal gate + título — peel de TurnPresence+Notifications+A11y.

enum TurnPresenceNotificationA11yTerminal {
    /// Só fases terminais publicadas pelo contrato de presença.
    static func isTerminal(_ presence: AtlasExecutionPresence) -> Bool {
        presence.timing == .finished
            && (presence.phaseTitle == "Concluído" || presence.phaseTitle == "Falhou")
    }

    static func title(from presence: AtlasExecutionPresence) -> String {
        presence.phaseTitle
    }
}
