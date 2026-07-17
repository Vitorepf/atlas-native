import SwiftUI
import AtlasCore

// Conteúdo da home (estados + listas CONVERSAS/OPERAÇÃO/WORKSPACES) —
// peel de RootView. Route e NavigationStack ficam no shell.
// Failure → RootHomeSections+Failure.swift; chips → RootHomeSections+Conversation.swift;
// loaded → RootHomeSections+Loaded.swift; a11y → RootHomeSections+A11y.swift.

struct RootHomeSections: View {
    @Environment(AtlasSession.self) private var session
    var reduceMotion: Bool
    @Binding var homeWorkspaceFilter: String?
    var onNavigate: (Route) -> Void
    var onOpenThread: (ThreadID, String) -> Void

    var body: some View {
        switch session.phase {
        case .idle where session.threads.isEmpty, .loading where session.threads.isEmpty:
            centered {
                WorkspaceLoadingEmpty(
                    reduceMotion: reduceMotion,
                    text: "abrindo o Atlas…",
                    spoken: "abrindo o Atlas",
                    topPadding: 0
                )
                .accessibilityIdentifier(A11yID.homeLoading)
            }

        case .failed where session.threads.isEmpty:
            failureSection

        default:
            loadedHome
        }
    }

    var rowDivider: some View {
        Divider().overlay(AtlasTheme.separator).padding(.leading, AtlasTheme.Space.screen + 36)
    }

    func centered<V: View>(@ViewBuilder _ v: () -> V) -> some View {
        VStack { Spacer(); v(); Spacer() }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
