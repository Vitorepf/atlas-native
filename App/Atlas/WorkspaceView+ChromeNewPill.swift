import SwiftUI
import AtlasCore

// Pílula nova conversa do Workspace (WAVE-002 W3 fuse label+chrome).

extension WorkspaceView {
    var newPill: some View {
        // A conversa nova nasce NESTE workspace (livres → sem workspace).
        // WAVE-016: face canônica AgenticPillFace (sem hand-roll chrome).
        NavigationLink(value: Route.new(workspaceKey: freeOnly ? nil : workspaceKey)) {
            AgenticPillFace(invite: workspacePillInvite)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("nova conversa")
        .accessibilityHint("abre o compositor para escrever ao Atlas")
        .accessibilityIdentifier(A11yID.workspaceNewPill)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
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
