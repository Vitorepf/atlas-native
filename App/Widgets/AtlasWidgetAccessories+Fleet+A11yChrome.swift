import WidgetKit
import SwiftUI
import AtlasCore

// Fleet a11y chrome — peel de FleetWidgetView+Body.
// SpokenLabel → AtlasWidgetAccessories+Fleet+A11yChrome+SpokenLabel.swift

extension FleetWidgetView {
    func fleetA11yChrome<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        stale: Bool
    ) -> some View {
        fleetA11ySpokenLabel(
            content
                .id(FleetWidgetA11y.contentPhaseID(snapshot: snapshot, stale: stale))
                .transaction { transaction in fleetA11yTransaction(&transaction) },
            snapshot: snapshot,
            stale: stale
        )
    }
}
