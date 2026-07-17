import WidgetKit
import SwiftUI
import AtlasCore

// Phase/id bind — peel de AtlasWidgetAccessories+Fleet+A11yChrome.
// Transaction → AtlasWidgetAccessories+Fleet+A11yChrome+PhaseBind+Transaction.swift
// Spoken → AtlasWidgetAccessories+Fleet+A11yChrome+PhaseBind+Spoken.swift
// SpokenLabel → AtlasWidgetAccessories+Fleet+A11yChrome+SpokenLabel.swift

extension FleetWidgetView {
    func fleetA11yPhaseBind<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        stale: Bool
    ) -> some View {
        fleetA11yPhaseSpoken(
            fleetA11yPhaseTransaction(content, snapshot: snapshot, stale: stale),
            snapshot: snapshot,
            stale: stale
        )
    }
}
