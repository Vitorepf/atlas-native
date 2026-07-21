import SwiftUI
import AtlasCore

// Strip activity row — peel de StatusActivity.

extension ExecutingStrip {
    @ViewBuilder
    func stripStatusActivityRow(_ act: AtlasAgentActivity) -> some View {
        HStack(spacing: 5) {
            Image(systemName: activityIcon(act.kind))
                .atlasSans(10, .semibold)
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
    }
}
