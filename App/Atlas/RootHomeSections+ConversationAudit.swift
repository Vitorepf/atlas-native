import SwiftUI
import AtlasCore

// Auditoria string — peel de RootHomeSections+ConversationCounts.

extension RootHomeSections {
    var auditDetail: String {
        let key = homeWorkspaceFilter ?? "livres"
        let n = homeConversationCount ?? 0
        return "auditoria · filtro \(key) · \(n) threads"
    }
}
