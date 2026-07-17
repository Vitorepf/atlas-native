import WidgetKit
import SwiftUI
import AtlasCore

// Fleet a11y chrome — peel de FleetWidgetView+Body.
// PhaseBind → AtlasWidgetAccessories+Fleet+A11yChrome+PhaseBind.swift
// SpokenLabel → AtlasWidgetAccessories+Fleet+A11yChrome+SpokenLabel.swift

extension FleetWidgetView {
    func fleetA11yChrome<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        stale: Bool
    ) -> some View {
        fleetA11yPhaseBind(content, snapshot: snapshot, stale: stale)
    }
}
