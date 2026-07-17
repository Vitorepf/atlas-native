import WidgetKit
import SwiftUI
import AtlasCore

// Header row — peel de AtlasWidgetAccessories+LiveSession+ContentStack.

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentHeaderRow(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        liveSessionContentHeader(snapshot: snapshot, stale: stale)
    }
}
