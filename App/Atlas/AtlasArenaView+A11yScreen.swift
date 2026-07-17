import SwiftUI
import AtlasCore

// Screen spoken — peel de AtlasArenaView+A11y.
// Failed → AtlasArenaView+A11yScreen+Failed.swift
// Busy → AtlasArenaView+A11yScreen+Busy.swift

extension AtlasArenaView {
    func spokenArenaScreenLabel() -> String {
        spokenArenaBusyLabel() ?? headerSpokenLabel
    }
}
