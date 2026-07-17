import WidgetKit
import SwiftUI
import AtlasCore

// Body gate — peel de AtlasWidgetAccessories+Fleet.

extension FleetWidgetView {
    @ViewBuilder
    func fleetBodyGate(snapshot: AtlasNativeSnapshot?, at date: Date) -> some View {
        guard let snapshot else {
            InstallPromptView()
        } else {
            fleetBody(snapshot: snapshot, stale: snapshot.isStale(at: date))
        }
    }
}
