import Foundation

// Queue chip A11yIDs — peel de A11yID+QueueLive.

extension A11yID {
    static let queueChip = "queue-chip"
    static let queueSheet = "queue-sheet"
    static let queueRowPrefix = "queue-row-"
    static let queuePromotePrefix = "queue-promote-"
    static let queueRemovePrefix = "queue-remove-"
    static func queueRow(_ index: Int) -> String { queueRowPrefix + String(index) }
    static func queuePromote(_ id: String) -> String { queuePromotePrefix + id }
    static func queueRemove(_ id: String) -> String { queueRemovePrefix + id }
}
