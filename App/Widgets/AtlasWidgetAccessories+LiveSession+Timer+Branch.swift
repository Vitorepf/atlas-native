import SwiftUI
import AtlasCore

// Active vs fallback branch — peel de AtlasWidgetAccessories+LiveSession+Timer.

extension LiveSessionWidgetTimer {
    @ViewBuilder
    var timerBranchBody: some View {
        if live.timing != .paused, let since = live.runningSince.flatMap(AtlasTime.date) {
            activeClock(since: since)
        } else {
            timerFallbackBody
        }
    }
}
