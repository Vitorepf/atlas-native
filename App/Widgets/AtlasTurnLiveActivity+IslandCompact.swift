import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Compact/minimal Island — peel de AtlasTurnLiveActivity+Island.
// Trailing/Minimal → +IslandCompact+Trailing.swift
// Symbol → AtlasTurnLiveActivity+IslandCompact+LeadingSymbol.swift

struct AtlasTurnIslandCompactLeading: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        leadingSymbol
    }
}
