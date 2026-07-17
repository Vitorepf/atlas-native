import SwiftUI
import AtlasCore

// Rhythm learning task — peel de AutonomosView+Lifecycle.

extension AutonomosView {
    func autonomosRhythmTask<Content: View>(_ content: Content) -> some View {
        content.task { await refreshRhythmLearning() }
    }
}
