import WidgetKit
import SwiftUI
import AtlasCore

// Live timer block — peel de AtlasWidgetAccessories+LiveSession+Bodies.

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionTimerBlock(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionTimerRow(live)
    }
}
