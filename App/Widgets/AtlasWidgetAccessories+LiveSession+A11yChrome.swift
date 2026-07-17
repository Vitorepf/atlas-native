import WidgetKit
import SwiftUI
import AtlasCore

// Live content a11y — peel de AtlasWidgetAccessories+LiveSession+Content.
// Transaction → AtlasWidgetAccessories+LiveSession+A11yTransaction.swift
// TransactionBind → AtlasWidgetAccessories+LiveSession+A11yChrome+TransactionBind.swift
// PhaseID → AtlasWidgetAccessories+LiveSession+A11yChrome+PhaseID.swift
// SpokenBind → AtlasWidgetAccessories+LiveSession+A11yChrome+SpokenBind.swift

extension LiveSessionWidgetView {
    func liveSessionA11yChrome<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> some View {
        liveSessionA11yTransactionBind(content, snapshot: snapshot, live: live, stale: stale)
    }
}
