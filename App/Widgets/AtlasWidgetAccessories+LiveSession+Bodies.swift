import WidgetKit
import SwiftUI
import AtlasCore

// Live branch — peel de LiveSessionWidgetView+Content.
// Titles → AtlasWidgetAccessories+LiveSession+Bodies+Titles.swift
// TimerBlock → AtlasWidgetAccessories+LiveSession+Bodies+TimerBlock.swift
// TimerRow → AtlasWidgetAccessories+LiveSession+Bodies+TimerRow.swift

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionActiveBody(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionTitlesBlock(live)
        liveSessionTimerBlock(live)
    }
}
