import WidgetKit
import SwiftUI
import AtlasCore

// Phase spoken bind — peel de AtlasWidgetAccessories+Fleet+A11yChrome+PhaseBind.

extension FleetWidgetView {
    func fleetA11yPhaseSpoken<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        stale: Bool
    ) -> some View {
        fleetA11ySpokenLabel(content, snapshot: snapshot, stale: stale)
    }
}
