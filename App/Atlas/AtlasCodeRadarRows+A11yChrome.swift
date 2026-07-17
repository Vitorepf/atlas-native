import AtlasCore
import SwiftUI

// Repo row a11y chrome — peel de AtlasCodeRadarRows.
// Button → AtlasCodeRadarRows+A11yChrome+Button.swift
// SpokenBind → AtlasCodeRadarRows+A11yChrome+SpokenBind.swift

extension AtlasCodeRepoRow {
    var repoRowA11yChrome: some View {
        repoRowSpokenBind(repoRowButton)
    }
}
