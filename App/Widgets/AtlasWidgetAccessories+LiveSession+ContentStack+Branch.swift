import WidgetKit
import SwiftUI
import AtlasCore

// Branch row — peel de AtlasWidgetAccessories+LiveSession+ContentStack.

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentBranchRow(
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?
    ) -> some View {
        liveSessionContentBranch(snapshot: snapshot, live: live)
    }
}
