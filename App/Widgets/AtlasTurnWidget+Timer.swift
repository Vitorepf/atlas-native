import SwiftUI
import ActivityKit
import AtlasCore

/// Relógio RM-safe compartilhado por Island/lock — paridade `LiveNowRow+Timing`.
/// A11y → AtlasTurnWidget+TimerA11y.swift
/// Text → AtlasTurnWidget+TimerText.swift
/// Frame → AtlasTurnWidget+Timer+Frame.swift
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
}
