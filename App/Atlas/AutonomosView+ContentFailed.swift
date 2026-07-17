import SwiftUI
import AtlasCore

// Failed content — peel de AutonomosView+ContentShell.

extension AutonomosView {
    func failedContent(message: String) -> some View {
        Group {
            preludeShell
            Spacer()
            AutonomosFleetFailureEmpty(message: message) { Task { await model.load() } }
            Spacer()
        }
    }
}
