import SwiftUI
import AtlasCore

// Status text do strip — peel de ExecutingStrip.
// Meta (timer/diff) → ConversationCockpit+ExecutingStrip+StatusMeta.swift

extension ExecutingStrip {
    @ViewBuilder
    var stripStatus: some View {
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
                    .accessibilityHidden(true)
            } else if let p = bubble.executionProgress {
                Text("\(p.current)/\(p.total) · \(p.title)")
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
                    .accessibilityHidden(true)
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
                        .accessibilityHidden(true)
                }
            } else {
                Text("Seguindo a execução")
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .layoutPriority(2)
                    .accessibilityHidden(true)
            }
            stripStatusMeta
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(stripAccessibilityLabel)
    }
}
