import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Live Activity + Dynamic Island — peel de AtlasWidgets.swift (régua ~120).
// Lock screen em AtlasTurnLockScreen.swift; Island em AtlasTurnLiveActivity+Island.

struct AtlasTurnLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AtlasTurnAttributes.self) { context in
            LockScreenView(context: context)
                .activityBackgroundTint(Ink.bg)
                .activitySystemActionForegroundColor(Ink.gold)
                .widgetURL(URL(string: "atlas://execution/\(context.attributes.threadKey)"))
        } dynamicIsland: { context in
            dynamicIslandContent(context: context)
        }
    }
}
