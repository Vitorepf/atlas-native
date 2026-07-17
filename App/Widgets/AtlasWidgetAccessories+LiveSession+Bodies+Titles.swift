import WidgetKit
import SwiftUI
import AtlasCore

// Live titles block — peel de AtlasWidgetAccessories+LiveSession+Bodies.
// TimerRow → AtlasWidgetAccessories+LiveSession+Bodies+TimerRow.swift

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionTitlesBlock(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionTitles(live)
    }
}
