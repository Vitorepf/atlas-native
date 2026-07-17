import WidgetKit
import SwiftUI
import AtlasCore

// Conteúdo live/silêncio — peel de LiveSessionWidgetView.
// Bodies → AtlasWidgetAccessories+LiveSession+Bodies.swift
// Header → AtlasWidgetAccessories+LiveSession+Header.swift
// A11y → AtlasWidgetAccessories+LiveSession+A11yChrome.swift
// Active → +ContentActive.swift · Silence → +ContentSilence.swift

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContent(snapshot: AtlasNativeSnapshot, live: AtlasNativeSnapshot.LiveSession?, stale: Bool) -> some View {
        liveSessionA11yChrome(
            VStack(alignment: .leading, spacing: 8) {
                liveSessionHeader(stale: stale, age: snapshot.ageText(at: entry.date))
                if let live {
                    liveSessionActiveBranch(live)
                } else {
                    liveSessionSilenceBranch(snapshot)
                }
            },
            snapshot: snapshot,
            live: live,
            stale: stale
        )
    }
}
