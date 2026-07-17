import SwiftUI
import ActivityKit
import AtlasCore

/// Relógio RM-safe compartilhado por Island/lock — paridade `LiveNowRow+Timing`.
/// A11y → AtlasTurnWidget+TimerA11y.swift
struct AtlasTurnWidgetTimer: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let startedAt: Date
    let paused: Bool?
    let pausedDisplay: String?
    var fontSize: CGFloat = 13
    var frameWidth: CGFloat? = 44
    var trailingPadding: CGFloat = 0

    var body: some View {
        Group {
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
        .font(.system(size: fontSize, design: .monospaced))
        .foregroundStyle(Ink.ink2)
        .frame(width: frameWidth)
        .padding(.trailing, trailingPadding)
        .accessibilityLabel(timerA11y)
    }

    func elapsedMs(now: Date) -> Int {
        Int(max(0, now.timeIntervalSince(startedAt)) * 1000)
    }
}
