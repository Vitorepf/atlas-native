import WidgetKit
import SwiftUI
import AtlasCore

// Snapshot gate — peel de AtlasWidgetAccessories+LiveSession.

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionSnapshotGate<Content: View>(
        @ViewBuilder content: (AtlasNativeSnapshot, AtlasNativeSnapshot.LiveSession?, Bool) -> Content
    ) -> some View {
        SnapshotContainer {
            guard let snapshot = entry.snapshot else {
                return AnyView(InstallPromptView())
            }
            let stale = snapshot.isStale(at: entry.date)
            let live = snapshot.liveSessions?.first
            return AnyView(content(snapshot, live, stale))
        }
    }
}
