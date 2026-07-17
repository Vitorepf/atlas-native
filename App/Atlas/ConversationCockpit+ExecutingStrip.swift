import SwiftUI
import AtlasCore

// ExecutingStrip — peel de ConversationCockpit (régua ≤110).

struct ExecutingStrip: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var onSteer: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
            if bubble.showsReconnectSurface {
                Image(systemName: bubble.reconnectBannerIcon)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                    .accessibilityHidden(true)
            } else {
                BreathingDiamond(size: 8, reduceMotion: reduceMotion)
            }
            if bubble.showsReconnectSurface, let line = bubble.reconnectPrimaryLine {
                Text(line)
                    .font(.system(.footnote))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
            } else if let p = bubble.executionProgress {
                Text("\(p.current)/\(p.total) · \(p.title)")
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
            } else if let act = bubble.currentActivity {
                HStack(spacing: 5) {
                    Image(systemName: activityIcon(act.kind))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                        .accessibilityHidden(true)
                    Text(act.title)
                        .font(.system(.footnote))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .layoutPriority(2)
                }
            } else {
                Text("Seguindo a execução")
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .layoutPriority(2)
            }
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel(stripAccessibilityLabel)
            Spacer(minLength: 0)
            stripActionButtons
        }
        .padding(.horizontal, 6)
        .lineLimit(1)
        .accessibilityElement(children: .contain)
    }
}
