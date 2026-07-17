import SwiftUI
import ActivityKit
import AtlasCore

// Timer paused/RM text — peel de AtlasTurnWidget+TimerText.

extension AtlasTurnWidgetTimer {
    @ViewBuilder
    var timerTextPausedOrRM: some View {
        if paused == true {
            Text("‖ \(pausedDisplay ?? "—")")
        } else if reduceMotion {
            TimelineView(.periodic(from: .now, by: 60)) { timeline in
                Text(AtlasTime.formatActiveDuration(milliseconds: elapsedMs(now: timeline.date)))
            }
        }
    }
}
