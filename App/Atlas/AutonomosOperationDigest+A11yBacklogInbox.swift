import Foundation

// Inbox backlog count — peel de AutonomosOperationDigest+A11yBacklog.

extension AutonomosOperationDigestA11y {
    static func spokenBacklogInbox(_ inboxCount: Int) -> String? {
        guard inboxCount > 0 else { return nil }
        return "\(inboxCount) decisão\(inboxCount == 1 ? "" : "ões") aguardando"
    }
}
