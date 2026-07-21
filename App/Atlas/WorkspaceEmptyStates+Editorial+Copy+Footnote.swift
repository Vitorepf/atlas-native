import SwiftUI
import AtlasCore

// Footnote copy — peel de WorkspaceEmptyStates+Editorial+Copy.

extension WorkspaceEditorialEmpty {
    var editorialFootnote: String {
        if freeOnly {
            return "perguntas e pensamento livre começam abaixo"
        }
        return "comece uma abaixo — o projeto é opcional"
    }
}
