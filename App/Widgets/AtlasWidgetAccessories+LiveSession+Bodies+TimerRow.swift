import WidgetKit
import SwiftUI
import AtlasCore

// Timer row — peel de AtlasWidgetAccessories+LiveSession+Bodies.

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionTimerRow(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        HStack {
            LiveSessionWidgetTimer(live: live)
            Spacer()
            liveSessionFollowChip
        }
    }
}
