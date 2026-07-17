import Foundation
import AtlasCore

/// Título/corpo/spoken da notificação local — peel de TurnPresence+Notifications (CICLO C).

enum TurnPresenceNotificationA11y {
    /// Só fases terminais publicadas pelo contrato de presença.
    static func isTerminal(_ presence: AtlasExecutionPresence) -> Bool {
        presence.timing == .finished
            && (presence.phaseTitle == "Concluído" || presence.phaseTitle == "Falhou")
    }

    static func title(from presence: AtlasExecutionPresence) -> String {
        presence.phaseTitle
    }

    /// Corpo só com dado real: excerpt da bolha do trace ou `detail` do ledger.
    static func body(
        presence: AtlasExecutionPresence,
        assistantExcerpt: String?,
        presentationDetail: String?
    ) -> String? {
        TurnPresenceNotificationA11yBody.body(
            presence: presence,
            assistantExcerpt: assistantExcerpt,
            presentationDetail: presentationDetail
        )
    }

    static func spoken(title: String, subtitle: String, body: String?) -> String {
        TurnPresenceNotificationA11ySpoken.spoken(title: title, subtitle: subtitle, body: body)
    }
}
