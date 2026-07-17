import Foundation
import AtlasCore

/// Corpo da notificação — peel de TurnPresence+Notifications+A11y.

@MainActor
enum TurnPresenceNotificationA11yBody {
    /// Corpo só com dado real: excerpt da bolha do trace ou `detail` do ledger.
    static func body(
        presence: AtlasExecutionPresence,
        assistantExcerpt: String?,
        presentationDetail: String?
    ) -> String? {
        switch presence.phaseTitle {
        case "Falhou":
            guard let detail = presentationDetail?
                .trimmingCharacters(in: .whitespacesAndNewlines), !detail.isEmpty else { return nil }
            return TurnPresence.lockScreenText(detail, limit: 140)
        case "Concluído":
            guard let excerpt = assistantExcerpt?
                .trimmingCharacters(in: .whitespacesAndNewlines), !excerpt.isEmpty else { return nil }
            return TurnPresence.lockScreenText(AtlasMarkdown.plainText(excerpt), limit: 140)
        default:
            return nil
        }
    }
}
