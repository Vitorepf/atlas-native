import SwiftUI
import AtlasCore

// Root home stack — peel de RootView.

extension RootView {
    var rootHomeStack: some View {
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
        .navigationBarHidden(true)
        .accessibilityIdentifier(A11yID.homeScreen)
        .accessibilityLabel(homeScreenSpokenLabel())
        .accessibilityHint(homeScreenSpokenHint())
        .navigationDestination(for: Route.self) { rootDestination(for: $0) }
    }
}
