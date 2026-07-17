import WidgetKit
import SwiftUI
import AtlasCore

// Live content a11y — peel de AtlasWidgetAccessories+LiveSession+Content.

extension LiveSessionWidgetView {
    func liveSessionA11yChrome<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> some View {
        content
            .id(LiveSessionWidgetA11y.contentPhaseID(snapshot: snapshot, live: live, stale: stale))
            .transaction { transaction in
                if reduceMotion { transaction.disablesAnimations = true }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(LiveSessionWidgetA11y.spokenLabel(
                snapshot: snapshot,
                live: live,
                stale: stale,
                age: snapshot.ageText(at: entry.date)
            ))
    }
}
