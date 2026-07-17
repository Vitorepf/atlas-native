import WidgetKit
import SwiftUI
import AtlasCore

// Spoken label bind — peel de AtlasWidgetAccessories+LiveSession+A11yChrome.

extension LiveSessionWidgetView {
    func liveSessionSpokenLabelBind<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(LiveSessionWidgetA11y.spokenLabel(
                snapshot: snapshot,
                live: live,
                stale: stale,
                age: snapshot.ageText(at: entry.date)
            ))
    }
}
