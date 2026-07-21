import SwiftUI
import AtlasCore

// Active status color — peel de ConversationCockpit+AgentStatus.

extension AgentRow {
    var statusColorActive: Color? {
        switch turnStatus {
        case .processing: return AtlasTheme.accent
        case .succeeded: return AtlasTheme.domAutonomos
        default: return nil
        }
    }
}
