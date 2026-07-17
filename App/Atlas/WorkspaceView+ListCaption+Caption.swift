import SwiftUI
import AtlasCore

// Visible caption — peel de WorkspaceView+ListCaption.

extension WorkspaceThreadsSection {
    var caption: String {
        if area == .tudo {
            return "\(threads.count) conversa\(threads.count == 1 ? "" : "s")"
        }
        return "\(threads.count) em \(area.label)"
    }
}
