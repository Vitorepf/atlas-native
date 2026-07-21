import SwiftUI
import AtlasCore

/// Spoken labels — peel de AtlasCodeRadarView (CICLO C residual honesty).
/// Shell fala só fase real e contagens do payload; ausência não inventa repositórios.
/// Spoken helpers → AtlasCodeRadarView+A11ySpoken.swift
/// Shell → AtlasCodeRadarView+A11yShell.swift
/// LoadedID → AtlasCodeRadarView+A11y+LoadedID.swift
/// BusyID → AtlasCodeRadarView+A11y+BusyID.swift

extension AtlasCodeRadarView {
    var contentPhaseID: String {
        contentPhaseBusyID ?? contentPhaseLoadedID
    }
}
