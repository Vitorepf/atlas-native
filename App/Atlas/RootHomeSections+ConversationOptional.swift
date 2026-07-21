import SwiftUI
import AtlasCore

// Optional count — peel de RootHomeSections+ConversationCounts.

extension RootHomeSections {
    var homeConversationCount: Int? {
        let n = homeConversationThreadCount
        return n > 0 ? n : nil
    }
}
