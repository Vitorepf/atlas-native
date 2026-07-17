import AtlasCore
import SwiftUI

// Repo row button — peel de AtlasCodeRadarRows+A11yChrome.
// SpokenBind → AtlasCodeRadarRows+A11yChrome+SpokenBind.swift

extension AtlasCodeRepoRow {
    var repoRowButton: some View {
        Button(action: onTap) {
            repoRowLabel
        }
        .buttonStyle(.plain)
    }
}
