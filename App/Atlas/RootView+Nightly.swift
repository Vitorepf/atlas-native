import AtlasCore
import SwiftUI

// Cycle 023 fuse → RootView+Nightly.swift

extension RootView {
    func registerNightlyOpen() {
        nightly.registerOpenAutonomos {
            path = NavigationPath()
            path.append(Route.autonomos)
        }
        #if DEBUG
        nightly.installDemoIfRequested()
        #endif
    }
}
