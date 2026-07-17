import WidgetKit
import SwiftUI
import AtlasCore

// Conteúdo live/silêncio — peel de LiveSessionWidgetView.
// Bodies → AtlasWidgetAccessories+LiveSession+Bodies.swift
// Header → AtlasWidgetAccessories+LiveSession+Header.swift
// A11y → AtlasWidgetAccessories+LiveSession+A11yChrome.swift
// Active → +ContentActive.swift · Silence → +ContentSilence.swift
// Stack → AtlasWidgetAccessories+LiveSession+ContentStack.swift

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContent(snapshot: AtlasNativeSnapshot, live: AtlasNativeSnapshot.LiveSession?, stale: Bool) -> some View {
        liveSessionA11yChrome(
            liveSessionContentStack(snapshot: snapshot, live: live, stale: stale),
            snapshot: snapshot,
            live: live,
            stale: stale
        )
    }
}
