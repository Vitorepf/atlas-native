import WidgetKit
import SwiftUI
import AtlasCore

// Fleet a11y chrome — peel de FleetWidgetView+Body.

extension FleetWidgetView {
    func fleetA11yChrome<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        stale: Bool
    ) -> some View {
        content
            .id(FleetWidgetA11y.contentPhaseID(snapshot: snapshot, stale: stale))
            .transaction { transaction in fleetA11yTransaction(&transaction) }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(FleetWidgetA11y.spokenLabel(
                snapshot: snapshot,
                stale: stale,
                at: entry.date,
                age: snapshot.ageText(at: entry.date)
            ))
    }
}
