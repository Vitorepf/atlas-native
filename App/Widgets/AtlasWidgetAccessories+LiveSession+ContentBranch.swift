import WidgetKit
import SwiftUI
import AtlasCore

// Live branch — peel de LiveSessionWidgetView content.

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentBranch(snapshot: AtlasNativeSnapshot, live: AtlasNativeSnapshot.LiveSession?) -> some View {
        if let live {
            liveSessionActiveBranch(live)
        } else {
            liveSessionSilenceBranch(snapshot)
        }
    }
}
