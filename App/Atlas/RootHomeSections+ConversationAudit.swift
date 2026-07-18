import SwiftUI
import AtlasCore

// Auditoria string — peel de RootHomeSections+ConversationCounts.

extension RootHomeSections {
    var auditDetail: String {
        let n = homeConversationCount ?? 0
        return "auditoria · livres · \(n) threads"
    }
}
