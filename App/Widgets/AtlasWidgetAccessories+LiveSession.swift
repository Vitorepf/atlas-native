import WidgetKit
import SwiftUI
import AtlasCore

// Home-screen live session widget — peel de LockLive (régua ~160).
// Content → AtlasWidgetAccessories+LiveSession+Content.swift
// SnapshotGate → AtlasWidgetAccessories+LiveSession+SnapshotGate.swift

struct LiveSessionWidgetView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let entry: SnapshotEntry

    var body: some View {
        liveSessionSnapshotGate { snapshot, live, stale in
            liveSessionContent(snapshot: snapshot, live: live, stale: stale)
        }
        .widgetURL(URL(string: "atlas://execution"))
    }
}
