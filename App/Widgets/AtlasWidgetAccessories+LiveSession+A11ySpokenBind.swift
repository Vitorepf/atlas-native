import WidgetKit
import SwiftUI
import AtlasCore

// Spoken label bind — peel de AtlasWidgetAccessories+LiveSession+A11yChrome.
// Combine → AtlasWidgetAccessories+LiveSession+A11ySpokenBind+Combine.swift
// Label → AtlasWidgetAccessories+LiveSession+A11ySpokenBind+Label.swift

extension LiveSessionWidgetView {
    func liveSessionSpokenLabelBind<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> some View {
        liveSessionSpokenCombine(content)
            .accessibilityLabel(
                liveSessionSpokenLabelText(snapshot: snapshot, live: live, stale: stale)
            )
    }
}
