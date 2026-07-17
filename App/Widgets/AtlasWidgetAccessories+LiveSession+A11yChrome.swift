import WidgetKit
import SwiftUI
import AtlasCore

// Live content a11y — peel de AtlasWidgetAccessories+LiveSession+Content.
// Transaction → AtlasWidgetAccessories+LiveSession+A11yTransaction.swift

extension LiveSessionWidgetView {
    func liveSessionA11yChrome<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> some View {
        content
            .id(LiveSessionWidgetA11y.contentPhaseID(snapshot: snapshot, live: live, stale: stale))
            .transaction { transaction in liveSessionA11yTransaction(&transaction) }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(LiveSessionWidgetA11y.spokenLabel(
                snapshot: snapshot,
                live: live,
                stale: stale,
                age: snapshot.ageText(at: entry.date)
            ))
    }
}
