import SwiftUI
import AtlasCore

// Handoff age — peel de ConversationChromeSheets+Receipt+Copy.

extension ConversationHandoffReceipt {
    var handoffAgeFragment: String? {
        guard let raw = handoff.createdAt, let date = AtlasTime.date(raw) else { return nil }
        return atlasRelativeAgePT(since: date)
    }
}
