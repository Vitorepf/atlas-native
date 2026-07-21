import SwiftUI
import AtlasCore

// New pill label — peel de WorkspaceView+ChromeNewPill.

extension WorkspaceView {
    // Mesma família chrome da home; invite = ocasião do workspace (WAVE-002).
    var newPillLabel: some View {
        HStack(spacing: 12) {
            RootView.HomeComposerStar()
            Text(workspacePillInvite)
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .atlasAgenticPillChrome()
    }

    private var workspacePillInvite: String {
        if freeOnly {
            return WorkspaceAskContext.freeInvite
        }
        if let workspaceKey {
            return WorkspaceAskContext.invite(workspaceName: title.isEmpty ? workspaceKey : title)
        }
        return HomeAskContext.invite
    }
}
