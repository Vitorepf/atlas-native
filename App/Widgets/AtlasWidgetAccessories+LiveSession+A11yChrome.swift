import WidgetKit
import SwiftUI
import AtlasCore

// Live content a11y — peel de AtlasWidgetAccessories+LiveSession+Content.
// Transaction → AtlasWidgetAccessories+LiveSession+A11yTransaction.swift
// PhaseID → AtlasWidgetAccessories+LiveSession+A11yChrome+PhaseID.swift
// SpokenBind → AtlasWidgetAccessories+LiveSession+A11yChrome+SpokenBind.swift

extension LiveSessionWidgetView {
    func liveSessionA11yChrome<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> some View {
        liveSessionA11yPhaseBind(
            content.transaction { transaction in liveSessionA11yTransaction(&transaction) },
            snapshot: snapshot,
            live: live,
            stale: stale
        )
    }
}
