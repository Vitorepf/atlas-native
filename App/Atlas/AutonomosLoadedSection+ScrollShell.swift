import SwiftUI
import AtlasCore

// Scroll shell — peel de AutonomosLoadedSection.

extension AutonomosLoadedSection {
    var loadedScrollShell: some View {
        loadedRefreshChrome(
            ScrollView {
                loadedStack
            }
        )
    }
}
