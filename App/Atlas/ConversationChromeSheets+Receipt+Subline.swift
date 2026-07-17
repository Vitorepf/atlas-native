import SwiftUI
import AtlasCore

// Handoff subline — peel de ConversationChromeSheets+Receipt+Copy.

extension ConversationHandoffReceipt {
    var subline: String {
        let route = "\(atlasSurfaceLabel(handoff.fromSurface)) → \(atlasSurfaceLabel(handoff.toSurface))"
        let thread = editorialThreadPrefix(handoff.threadId)
        let age = handoffAgeFragment
        if isReady {
            var parts = ["\(route)", "mesma thread \(thread)", "sem prompt duplicado"]
            if let age { parts.append("há \(age)") }
            return parts.joined(separator: " · ")
        }
        var parts = [atlasHandoffStatusEditorial(handoff.status), route, "thread \(thread)"]
        if let age { parts.append("há \(age)") }
        return parts.joined(separator: " · ")
    }
}
