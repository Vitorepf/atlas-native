import SwiftUI
import AtlasCore

// Home loading shell — peel de RootHomeSections.

extension RootHomeSections {
    var loadingHome: some View {
        centered {
            WorkspaceLoadingEmpty(
                reduceMotion: reduceMotion,
                text: "abrindo o Atlas…",
                spoken: "abrindo o Atlas",
                topPadding: 0
            )
            .accessibilityIdentifier(A11yID.homeLoading)
        }
    }
}
