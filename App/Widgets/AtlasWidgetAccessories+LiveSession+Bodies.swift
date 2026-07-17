import WidgetKit
import SwiftUI
import AtlasCore

// Live branch — peel de LiveSessionWidgetView+Content.
// Silence → AtlasWidgetAccessories+LiveSession+Silence.swift
// Follow → AtlasWidgetAccessories+LiveSession+Follow.swift
// Titles → AtlasWidgetAccessories+LiveSession+Titles.swift

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionActiveBody(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionTitles(live)
        HStack {
            LiveSessionWidgetTimer(live: live)
            Spacer()
            liveSessionFollowChip
        }
    }
}
