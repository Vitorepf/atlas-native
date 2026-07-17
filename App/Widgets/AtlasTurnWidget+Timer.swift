import SwiftUI
import ActivityKit
import AtlasCore

/// Relógio RM-safe compartilhado por Island/lock — paridade `LiveNowRow+Timing`.
struct AtlasTurnWidgetTimer: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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

    private func elapsedMs(now: Date) -> Int {
        Int(max(0, now.timeIntervalSince(startedAt)) * 1000)
    }

    private var timerA11y: String {
        if paused == true {
            return "tempo ativo congelado em \(pausedDisplay ?? "indisponível")"
        }
        return "tempo ativo"
    }
}
