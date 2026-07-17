import WidgetKit
import SwiftUI
import AtlasCore

// Phase transaction bind — peel de AtlasWidgetAccessories+Fleet+A11yChrome+PhaseBind.

extension FleetWidgetView {
    func fleetA11yPhaseTransaction<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        stale: Bool
    ) -> some View {
        content
            .id(FleetWidgetA11y.contentPhaseID(snapshot: snapshot, stale: stale))
            .transaction { transaction in fleetA11yTransaction(&transaction) }
    }
}
