import SwiftUI
import AtlasCore

// Root home stack — peel de RootView.
// Chrome → RootView+HomeChrome.swift

extension RootView {
    var rootHomeStack: some View {
        rootHomeNavChrome(
            ZStack(alignment: .bottom) {
                homeAtmosphere
                rootHomeSectionsStack
                inputBar
            }
        )
    }
}
