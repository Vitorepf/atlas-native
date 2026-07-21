import SwiftUI
import AtlasCore

// Free thread count — peel de RootHomeSections+ConversationCounts.

extension RootHomeSections {
    var freeThreadCount: Int {
        session.threads.filter { $0.workspace == nil }.count
    }
}
