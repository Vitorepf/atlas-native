import SwiftUI
import AtlasCore

// Pending subline — peel de ConversationChromeSheets+Receipt+Subline.

extension ConversationHandoffReceipt {
    func pendingSubline(route: String, thread: String, age: String?) -> String {
        var parts = [atlasHandoffStatusEditorial(handoff.status), route, "thread \(thread)"]
        if let age { parts.append("há \(age)") }
        return parts.joined(separator: " · ")
    }
}
