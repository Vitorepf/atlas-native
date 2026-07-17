import SwiftUI

// Mount header counter — peel de ArtifactSheet+MountHeader.
// Progress text → ArtifactSheet+MountCounter+ProgressText.swift

extension ArtifactSheet {
    var mountHeaderCounter: some View {
        HStack(spacing: 8) {
            mountCounterText
            if !mountComplete {
                BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 0)
        }
    }
}
