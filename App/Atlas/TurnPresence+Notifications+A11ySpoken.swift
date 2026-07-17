import Foundation

/// Spoken da notificação — peel de TurnPresence+Notifications+A11y.

enum TurnPresenceNotificationA11ySpoken {
    static func spoken(title: String, subtitle: String, body: String?) -> String {
        guard let body, !body.isEmpty else { return "\(title), \(subtitle)" }
        return "\(title), \(subtitle). \(body)"
    }
}
