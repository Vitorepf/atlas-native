import SwiftUI
import AtlasCore

// Root home stack — peel de RootView.
// Chrome → RootView+HomeChrome.swift

extension RootView {
    var rootHomeStack: some View {
        rootHomeNavChrome(
            ZStack(alignment: .bottom) {
                AtlasTheme.bg.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    topBar
                        .padding(.horizontal, AtlasTheme.Space.screen)
                        .padding(.top, 4)
                        .padding(.bottom, 14)

                    RootHomeSections(
                        reduceMotion: reduceMotion,
                        homeWorkspaceFilter: $homeWorkspaceFilter,
                        onNavigate: { path.append($0) },
                        onOpenThread: { id, title in path.append(Route.thread(id: id, title: title)) }
                    )
                }

                inputBar
            }
        )
    }
}
