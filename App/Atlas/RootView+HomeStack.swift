import SwiftUI
import AtlasCore

// Root home stack — peel de RootView.
// Chrome → RootView+HomeChrome.swift

extension RootView {
    var rootHomeStack: some View {
        rootHomeNavChrome(
            ZStack(alignment: .bottom) {
                AtlasTheme.bg.ignoresSafeArea()
                rootHomeSectionsStack
                inputBar
            }
        )
    }
}
