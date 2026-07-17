import WidgetKit
import SwiftUI
import AtlasCore

// Fleet body header+state — peel de Fleet Body Stack.

extension FleetWidgetView {
    @ViewBuilder
    func fleetBodyLeadRows(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        fleetBodyHeaderRow(snapshot: snapshot, stale: stale)
        fleetBodyStateRow(snapshot)
    }
}
