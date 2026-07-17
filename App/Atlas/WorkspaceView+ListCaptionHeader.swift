import SwiftUI
import AtlasCore

// Caption header — peel de WorkspaceView+ListCaption.

extension WorkspaceThreadsSection {
    var captionHeader: some View {
        Text(caption.uppercased())
            .font(.system(.caption, weight: .semibold)).tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(spokenCaption)
            .accessibilityIdentifier(A11yID.workspaceThreadsCaption)
    }
}
