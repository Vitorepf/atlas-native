import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Symbol branch — peel de AtlasTurnLiveActivity+IslandCompact.
// Multi → AtlasTurnLiveActivity+IslandCompact+LeadingSymbol+Multi.swift
// Single → AtlasTurnLiveActivity+IslandCompact+LeadingSymbol+Single.swift

extension AtlasTurnIslandCompactLeading {
    @ViewBuilder
    var leadingSymbol: some View {
        if context.state.activeSessions > 1 {
            leadingSymbolMulti
        } else {
            leadingSymbolSingle
        }
    }
}
