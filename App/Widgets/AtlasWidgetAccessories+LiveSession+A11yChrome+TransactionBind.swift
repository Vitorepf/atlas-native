import WidgetKit
import SwiftUI
import AtlasCore

// Transaction bind — peel de AtlasWidgetAccessories+LiveSession+A11yChrome.
// PhaseID → AtlasWidgetAccessories+LiveSession+A11yChrome+PhaseID.swift
// SpokenBind → AtlasWidgetAccessories+LiveSession+A11yChrome+SpokenBind.swift

extension LiveSessionWidgetView {
    func liveSessionA11yTransactionBind<Content: View>(
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
