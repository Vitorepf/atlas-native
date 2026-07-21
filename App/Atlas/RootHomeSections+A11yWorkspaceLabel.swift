import AtlasCore
import SwiftUI

// Workspace chip spoken — peel de RootHomeSections+A11y.

extension RootHomeSections {
    func workspaceSpokenLabel(name: String, count: Int?) -> String {
        guard let count else { return name }
        return "\(name), \(count) conversa\(count == 1 ? "" : "s")"
    }
}
