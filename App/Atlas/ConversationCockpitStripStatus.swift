import SwiftUI
import AtlasCore

// WAVE-156 density peel — ExecutingStrip status

extension ExecutingStrip {
    // MARK: Status

    @ViewBuilder
    var stripStatus: some View {
        HStack(spacing: 8) {
            stripStatusLeading
            stripStatusTitle
            if face != .finished && face != .quiet {
                stripStatusMeta
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(stripAccessibilityLabel)
    }

    @ViewBuilder
    var stripStatusLeading: some View {
        // Face reconnect (includes dual-surface primary ownership for WAVE-012).
        if face == .reconnect {
            Image(systemName: bubble.reconnectBannerIcon)
                .atlasSans(10, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                .accessibilityHidden(true)
        } else if face == .paused {
            Text("‖")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        } else if face == .finished {
            Image(systemName: "checkmark")
                .atlasSans(10, .bold)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        } else {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
        }
    }

    @ViewBuilder
    var stripStatusTitle: some View {
        // WAVE-027/031: primary kicker = face/decision spoken; detail secondary.
        HStack(spacing: 6) {
            Text(ConversationExecutionPhase.primarySpoken(for: bubble))
                .font(AtlasFont.mono(11, .semibold))
                .foregroundStyle(
                    decisionRequired
                        ? AtlasTheme.accent
                        : (face == .quiet || face == .finished
                            ? AtlasTheme.textTertiary
                            : AtlasTheme.textSecondary)
                )
                .lineLimit(1)
                .layoutPriority(3)
                .accessibilityHidden(true)
            stripStatusDetail
        }
    }

    @ViewBuilder
    var stripStatusDetail: some View {
        switch face {
        case .reconnect:
            if bubble.showsReconnectSurface, let line = bubble.reconnectPrimaryLine {
                Text(line)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
                    .accessibilityHidden(true)
            }
        case .multiAgent, .running:
            // WAVE-040: shared plan progress grammar with PlanCard.
            if bubble.executionPlan != nil || bubble.executionProgress != nil {
                Text(PlanJudgment.summaryLine(bubble: bubble))
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
                    .accessibilityHidden(true)
            } else if let act = bubble.currentActivity {
                Text(act.title)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
                    .accessibilityHidden(true)
            }
        case .finished, .paused, .quiet:
            EmptyView()
        }
    }

    @ViewBuilder
    var stripStatusMeta: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let secs = bubble.startedAt.map { max(0, Int(ctx.date.timeIntervalSince($0))) } ?? 0
            Text("· \(bubble.activities.count) evento\(bubble.activities.count == 1 ? "" : "s") · \(secs)s")
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .lineLimit(1)
                .accessibilityHidden(true)
        }
        if let stats = bubble.diffStats {
            Text("+\(stats.linesAdded) −\(stats.linesRemoved)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}
