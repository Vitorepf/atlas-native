import AtlasCore
import SwiftUI

// Conversas entry spoken — peel de RootHomeSections Conversation a11y.

extension RootHomeSections {
    func conversasEntrySpokenLabel() -> String {
        var parts = [homeConversationLabel]
        let n = homeConversationThreadCount
        if n == 0 {
            parts.append("nenhuma conversa")
        } else {
            parts.append("\(n) conversa\(n == 1 ? "" : "s")")
        }
        if session.auditModeEnabled {
            parts.append(auditDetail)
        }
        return parts.joined(separator: ", ")
    }
}
