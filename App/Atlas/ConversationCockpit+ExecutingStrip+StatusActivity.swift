import SwiftUI
import AtlasCore

// Strip status title activity branch — peel de StatusTitle.

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusActivityOrIdle: some View {
        if let act = bubble.currentActivity {
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
    }
}
