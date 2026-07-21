import Foundation

// Conversation outline row A11yID — peel de A11yID+QueueLive.

extension A11yID {
    static func conversationOutlineRow(_ index: Int) -> String { conversationOutlineRowPrefix + String(index) }
}
