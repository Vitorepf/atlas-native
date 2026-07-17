import SwiftUI
import ActivityKit
import AtlasCore

// Timer text branches — peel de AtlasTurnWidget+Timer.
// Elapsed → AtlasTurnWidget+TimerElapsed.swift

extension AtlasTurnWidgetTimer {
    @ViewBuilder
    var timerText: some View {
        if paused == true {
            Text("‖ \(pausedDisplay ?? "—")")
        } else if reduceMotion {
            TimelineView(.periodic(from: .now, by: 60)) { timeline in
                Text(AtlasTime.formatActiveDuration(milliseconds: elapsedMs(now: timeline.date)))
            }
        } else {
            Text(startedAt, style: .timer)
        }
    }
}
