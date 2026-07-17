import SwiftUI

// Mount header — peel de ArtifactSheet+Mount.
// Counter → ArtifactSheet+MountCounter.swift

extension ArtifactSheet {
    var mountHeader: some View {
        mountHeaderCounter
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(mountSpoken)
    }
}
