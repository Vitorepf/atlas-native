import SwiftUI
import AtlasCore

// Copy do empty workspace — peel de WorkspaceEditorialEmpty.
// Spoken → WorkspaceEmptyStates+Editorial+Spoken.swift

extension WorkspaceEditorialEmpty {
    var headline: String {
        if area != .tudo {
            return "“Nada em \(area.label) — por enquanto.”"
        }
        if freeOnly {
            return "“Nenhuma conversa sem projeto ainda.”"
        }
        return "“Nenhuma conversa em \(screenTitle) ainda.”"
    }

    var footnote: String {
        if freeOnly {
            return "perguntas e pensamento livre começam abaixo"
        }
        return "comece uma abaixo — o projeto é opcional"
    }
}
