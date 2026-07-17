import WidgetKit
import SwiftUI
import AtlasCore

// Spoken label bind — peel de Fleet+A11yChrome.

extension FleetWidgetView {
    func fleetA11ySpokenLabel<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        stale: Bool
    ) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(FleetWidgetA11y.spokenLabel(
                snapshot: snapshot,
                stale: stale,
                at: entry.date,
                age: snapshot.ageText(at: entry.date)
            ))
    }
}
