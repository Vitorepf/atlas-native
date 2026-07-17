import WidgetKit
import SwiftUI
import AtlasCore

// Superfícies externas do Atlas. Widgets/accessories leem somente o snapshot
// SD-1 no App Group; a Live Activity recebe estado via ActivityKit/APNs.
// Definitions → AtlasWidgets+Definitions.swift
// Paleta em WidgetsInk.swift; provider/container em AtlasWidgetViews.swift;
// superfícies em AtlasWidgetAccessories+CodeWeekFleet.swift e +LockLive.swift;
// lock screen em AtlasTurnLockScreen.swift; Live Activity em AtlasTurnLiveActivity.swift.

@main
struct AtlasWidgetsBundle: WidgetBundle {
    var body: some Widget {
        AtlasFleetWidget()
        AtlasLockAccessoryWidget()
        AtlasLiveSessionWidget()
        AtlasCodeWeekWidget()
        AtlasTurnLiveActivity()
    }
}
