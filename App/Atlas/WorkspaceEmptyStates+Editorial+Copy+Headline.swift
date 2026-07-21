import SwiftUI
import AtlasCore

// Headline copy — peel de WorkspaceEmptyStates+Editorial+Copy.

extension WorkspaceEditorialEmpty {
    var editorialHeadline: String {
        if area != .tudo {
            return "“Nada em \(area.label) — por enquanto.”"
        }
        if freeOnly {
            return "“Nenhuma conversa sem projeto ainda.”"
        }
        return "“Nenhuma conversa em \(screenTitle) ainda.”"
    }
}
