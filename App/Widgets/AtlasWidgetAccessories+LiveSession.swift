import WidgetKit
import SwiftUI
import AtlasCore

// Home-screen live session widget — peel de LockLive (régua ~160).
// Content → AtlasWidgetAccessories+LiveSession+Content.swift

struct LiveSessionWidgetView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let entry: SnapshotEntry

    var body: some View {
        SnapshotContainer {
            guard let snapshot = entry.snapshot else {
                return AnyView(InstallPromptView())
            }
            let stale = snapshot.isStale(at: entry.date)
            let live = snapshot.liveSessions?.first
            return AnyView(liveSessionContent(snapshot: snapshot, live: live, stale: stale))
        }
        .widgetURL(URL(string: "atlas://execution"))
    }
}
