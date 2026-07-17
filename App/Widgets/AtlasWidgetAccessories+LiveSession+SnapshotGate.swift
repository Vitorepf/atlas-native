import WidgetKit
import SwiftUI
import AtlasCore

// Snapshot gate — peel de AtlasWidgetAccessories+LiveSession.
// Install → AtlasWidgetAccessories+LiveSession+SnapshotGate+Install.swift

extension LiveSessionWidgetView {
    func liveSessionSnapshotGate<Content: View>(
        @ViewBuilder content: @escaping (AtlasNativeSnapshot, AtlasNativeSnapshot.LiveSession?, Bool) -> Content
    ) -> some View {
        SnapshotContainer {
            liveSessionInstallGate(snapshot: entry.snapshot) { snapshot in
                let stale = snapshot.isStale(at: entry.date)
                let live = snapshot.liveSessions?.first
                content(snapshot, live, stale)
            }
        }
    }
}
