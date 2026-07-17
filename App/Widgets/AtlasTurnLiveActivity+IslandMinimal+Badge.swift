import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Phase badge branch — peel de AtlasTurnLiveActivity+IslandMinimal.

extension AtlasTurnIslandMinimal {
    func islandMinimalBadge(_ badge: String) -> some View {
        Text(badge)
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundStyle(Ink.alert)
    }
}
