import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Multi-session symbol — peel de AtlasTurnLiveActivity+IslandCompact+LeadingSymbol.

extension AtlasTurnIslandCompactLeading {
    var leadingSymbolMulti: some View {
        Text("\(context.state.atlasSymbol)\(context.state.activeSessions)")
            .font(.system(size: 13, weight: .semibold, design: .serif))
            .foregroundStyle(context.state.atlasColor)
    }
}
