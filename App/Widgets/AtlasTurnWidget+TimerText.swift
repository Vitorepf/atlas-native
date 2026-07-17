import SwiftUI
import ActivityKit
import AtlasCore

// Timer text branches — peel de AtlasTurnWidget+Timer.
// Elapsed → AtlasTurnWidget+TimerElapsed.swift
// PausedRM → AtlasTurnWidget+TimerText+PausedRM.swift

extension AtlasTurnWidgetTimer {
    @ViewBuilder
    var timerText: some View {
        if paused == true || reduceMotion {
            timerTextPausedOrRM
        } else {
            Text(startedAt, style: .timer)
        }
    }
}
