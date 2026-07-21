import SwiftUI
import ActivityKit
import AtlasCore

/// Relógio RM-safe compartilhado por Island/lock — paridade LiveNowRow+Timing.
/// WAVE-018: honesty — paused shows frozen display or "—", never invent 0:00.
struct AtlasTurnWidgetTimer: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let startedAt: Date
    let paused: Bool?
    let pausedDisplay: String?
    var fontSize: CGFloat = 13
    var frameWidth: CGFloat? = 44
    var trailingPadding: CGFloat = 0

    var body: some View {
        timerFrameChrome
            .accessibilityLabel(timerA11y)
    }

    var timerFrameChrome: some View {
        timerText
            .font(.system(size: fontSize, design: .monospaced))
            .foregroundStyle(Ink.ink2)
            .frame(width: frameWidth)
            .padding(.trailing, trailingPadding)
    }

    var timerA11y: String {
        if paused == true {
            return "tempo ativo congelado em \(pausedDisplay ?? "indisponível")"
        }
        return "tempo ativo"
    }

    @ViewBuilder
    var timerText: some View {
        if paused == true || reduceMotion {
            timerTextPausedOrRM
        } else {
            Text(startedAt, style: .timer)
        }
    }

    @ViewBuilder
    var timerTextPausedOrRM: some View {
        if paused == true {
            // Honesty: missing pausedDisplay → em dash, never "0:00"
            Text("‖ \(pausedDisplay ?? "—")")
        } else if reduceMotion {
            TimelineView(.periodic(from: .now, by: 60)) { timeline in
                Text(AtlasTime.formatActiveDuration(milliseconds: elapsedMs(now: timeline.date)))
            }
        }
    }

    func elapsedMs(now: Date) -> Int {
        Int(max(0, now.timeIntervalSince(startedAt)) * 1000)
    }
}
