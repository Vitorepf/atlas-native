import SwiftUI
import AtlasCore

// Spoken caption — peel de WorkspaceView+ListCaption.

extension WorkspaceThreadsSection {
    var spokenCaption: String {
        if area == .tudo {
            return "\(threads.count) conversa\(threads.count == 1 ? "" : "s") em \(screenTitle)"
        }
        return "\(threads.count) conversa\(threads.count == 1 ? "" : "s") em \(area.label), \(screenTitle)"
    }
}
