import SwiftUI
import AtlasCore

// Phase + remote badge — peel de LiveNowRow+ContentTitle.

extension LiveNowRow {
    var rowPhaseLine: some View {
        HStack(spacing: 6) {
            Text(session.phaseTitle)
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
            if session.isRemote {
                remoteBadge
            }
        }
    }
}
