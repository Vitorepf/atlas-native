import WidgetKit
import SwiftUI
import AtlasCore

// Live session header row — peel de AtlasWidgetAccessories+LiveSession+Content.

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentHeader(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        liveSessionHeader(stale: stale, age: snapshot.ageText(at: entry.date))
    }
}
