import AtlasCore
import SwiftUI

// Row layout — peel de AtlasCodeRadarRows+Label.
// Leading → AtlasCodeRadarRows+Label+Leading.swift

extension AtlasCodeRepoRow {
    var repoRowLabel: some View {
        HStack(alignment: .center, spacing: 12) {
            repoRowLeading
            Spacer(minLength: 6)
            repoRowTrailing
        }
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}
