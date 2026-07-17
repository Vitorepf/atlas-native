import Foundation
import AtlasCore

/// Título/corpo/spoken da notificação local — peel de TurnPresence+Notifications (CICLO C).

enum TurnPresenceNotificationA11y {
    static func isTerminal(_ presence: AtlasExecutionPresence) -> Bool {
        TurnPresenceNotificationA11yTerminal.isTerminal(presence)
    }

    static func title(from presence: AtlasExecutionPresence) -> String {
        TurnPresenceNotificationA11yTerminal.title(from: presence)
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
