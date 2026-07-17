import WidgetKit
import SwiftUI
import AtlasCore

// Content stack — peel de AtlasWidgetAccessories+LiveSession+Content.

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentStack(snapshot: AtlasNativeSnapshot, live: AtlasNativeSnapshot.LiveSession?, stale: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            liveSessionContentHeader(snapshot: snapshot, stale: stale)
            liveSessionContentBranch(snapshot: snapshot, live: live)
        }
    }
}
