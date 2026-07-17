import Foundation

// Queue + LiveNow A11yIDs — peel de A11yID.swift.

extension A11yID {
    static let queueChip = "queue-chip"
    static let queueSheet = "queue-sheet"
    static let queueRowPrefix = "queue-row-"
    static let queuePromotePrefix = "queue-promote-"
    static let queueRemovePrefix = "queue-remove-"
    static func queueRow(_ index: Int) -> String { queueRowPrefix + String(index) }
    static func queuePromote(_ id: String) -> String { queuePromotePrefix + id }
    static func queueRemove(_ id: String) -> String { queueRemovePrefix + id }

    static let liveNowSection = "live-now-section"
    static let liveNowRowPrefix = "live-now-row-"
    static let liveNowRemoteBadgePrefix = "live-now-remote-badge-"
    static func liveNowRow(_ index: Int) -> String { liveNowRowPrefix + String(index) }
    static func liveNowRemoteBadge(_ index: Int) -> String { liveNowRemoteBadgePrefix + String(index) }
    static func conversationOutlineRow(_ index: Int) -> String { conversationOutlineRowPrefix + String(index) }
}
