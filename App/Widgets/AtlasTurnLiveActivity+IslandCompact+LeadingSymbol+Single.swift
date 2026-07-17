import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Single-session symbol — peel de AtlasTurnLiveActivity+IslandCompact+LeadingSymbol.

extension AtlasTurnIslandCompactLeading {
    var leadingSymbolSingle: some View {
        Text(context.state.atlasSymbol)
            .font(.system(size: 15, design: .serif))
            .foregroundStyle(context.state.atlasColor)
    }
}
