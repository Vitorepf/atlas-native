import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// WAVE-018 — Lock screen fused host (same glance grammar as Island).

struct LockScreenView: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        HStack(spacing: 14) {
            lockScreenLeadingColumn
            Spacer()
            trailingStatus
        }
        .padding(.horizontal, 18).padding(.vertical, 14)
    }

    @ViewBuilder
    var lockScreenLeadingColumn: some View {
        Text(context.state.atlasSymbol)
            .font(.system(size: 28, design: .serif))
            .foregroundStyle(context.state.atlasColor)
            .shadow(color: context.state.atlasColor.opacity(0.35), radius: 4)
        VStack(alignment: .leading, spacing: 3) {
            titleBadges
            phaseLine
            progressLine
        }
    }

    var titleBadges: some View {
        HStack(spacing: 7) {
            Text(context.attributes.threadTitle)
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink).lineLimit(1)
            activeSessionsBadge
            queueCapsule
        }
    }

    @ViewBuilder
    var activeSessionsBadge: some View {
        if context.state.glanceFace == .multiSession {
            Text("× \(context.state.activeSessions)")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.gold)
                .padding(.horizontal, 7).padding(.vertical, 2)
                .background(Capsule().fill(Ink.gold.opacity(0.14)))
        }
    }

    @ViewBuilder
    var queueCapsule: some View {
        if let queued = context.state.queueLabel {
            Text(queued)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.gold)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().fill(Ink.gold.opacity(0.22)))
                .overlay(Capsule().stroke(Ink.gold.opacity(0.45), lineWidth: 0.5))
                .accessibilityLabel(queued)
        }
    }

    var phaseLine: some View {
        HStack(spacing: 6) {
            phaseBadgeChip
            Text(context.state.phaseTitle)
                .font(.system(size: 13, design: .serif)).italic()
                .foregroundStyle(context.state.silenceHealthyFinished ? Ink.healed : context.state.atlasColor)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    var phaseBadgeChip: some View {
        if let badge = context.state.phaseBadge {
            Text(badge)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(Capsule().fill(Ink.alert.opacity(0.16)))
                .accessibilityLabel(context.state.phaseTitle)
        }
    }

    @ViewBuilder
    var progressLine: some View {
        if let progress = context.state.progressLabel {
            Text(progress)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        }
    }

    @ViewBuilder
    var trailingStatus: some View {
        // Face exclusive: finished silences timer (no false 0:00).
        if context.state.glanceFace == .finished {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22)).foregroundStyle(Ink.healed)
                .accessibilityLabel("concluído")
        } else if context.state.showsGlanceTimer {
            AtlasTurnWidgetTimer(
                startedAt: context.state.startedAt,
                paused: context.state.paused,
                pausedDisplay: context.state.pausedDisplay,
                fontSize: 15,
                frameWidth: 52
            )
        }
    }
}
