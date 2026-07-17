import WidgetKit
import SwiftUI
import AtlasCore

// Phase ID bind — peel de AtlasWidgetAccessories+LiveSession+A11yChrome.

extension LiveSessionWidgetView {
    func liveSessionA11yPhaseBind<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> some View {
        liveSessionSpokenLabelBind(
            liveSessionA11yPhaseID(content, snapshot: snapshot, live: live, stale: stale),
            snapshot: snapshot,
            live: live,
            stale: stale
        )
    }
}
