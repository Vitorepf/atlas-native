import SwiftUI
import AtlasCore

// Autonomos loaded refresh chrome — peel de AutonomosLoadedSection.

extension AutonomosLoadedSection {
    func loadedRefreshChrome<Content: View>(_ content: Content) -> some View {
        content
            .refreshable {
                await model.load()
            }
            .scrollIndicators(.hidden)
    }
}
