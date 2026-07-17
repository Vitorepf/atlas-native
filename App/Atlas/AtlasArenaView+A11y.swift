import SwiftUI
import AtlasCore

/// Spoken labels e gates de silêncio — peel de AtlasArenaView (CICLO C residual honesty).
/// Domain/run → AtlasArenaView+DomainA11y.swift
/// Screen → AtlasArenaView+A11yScreen.swift
/// Header → AtlasArenaView+A11yHeader.swift
/// FailedID → AtlasArenaView+A11y+FailedID.swift
/// BusyID → AtlasArenaView+A11y+BusyID.swift

extension AtlasArenaView {
    var contentPhaseID: String {
        contentPhaseBusyID ?? contentPhaseFailedID
    }
}
