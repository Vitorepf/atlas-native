import Foundation

// Operation digest backlog parts — peel de AutonomosOperationDigest+A11yCounts.
// Pending → AutonomosOperationDigest+A11yBacklogPending.swift
// Inbox → AutonomosOperationDigest+A11yBacklogInbox.swift
// Oldest → AutonomosOperationDigest+A11yBacklogOldest.swift

extension AutonomosOperationDigestA11y {
    static func spokenBacklogParts(
        pendingCount: Int,
        inboxCount: Int,
        oldestBacklogCreatedAt: Date?
    ) -> [String] {
        var parts: [String] = []
        if let pending = spokenBacklogPending(pendingCount) { parts.append(pending) }
        if let inbox = spokenBacklogInbox(inboxCount) { parts.append(inbox) }
        if let oldest = spokenBacklogOldest(oldestBacklogCreatedAt) { parts.append(oldest) }
        return parts
    }
}
