import SwiftUI
import AtlasCore

// Spoken label — peel de WorkspaceEmptyStates+Editorial+Copy.

extension WorkspaceEditorialEmpty {
    var spokenLabel: String {
        let lead: String
        if area != .tudo {
            lead = "nada em \(area.label) em \(screenTitle)"
        } else if freeOnly {
            lead = "nenhuma conversa sem projeto ainda"
        } else {
            lead = "nenhuma conversa em \(screenTitle) ainda"
        }
        return "\(lead). \(footnote)"
    }
}
