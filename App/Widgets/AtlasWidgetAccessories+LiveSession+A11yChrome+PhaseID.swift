import WidgetKit
import SwiftUI
import AtlasCore

// Phase ID bind — peel de LiveSession+A11yChrome.

extension LiveSessionWidgetView {
    func liveSessionA11yPhaseID<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> some View {
        content.id(LiveSessionWidgetA11y.contentPhaseID(snapshot: snapshot, live: live, stale: stale))
    }
}
