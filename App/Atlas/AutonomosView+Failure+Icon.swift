import SwiftUI

// Failure icon — peel de AutonomosView+Failure.

extension AutonomosFleetFailureEmpty {
    var failureIcon: some View {
        Image(systemName: "exclamationmark.triangle")
            .font(.title2)
            .foregroundStyle(AtlasTheme.domOperacional)
            .accessibilityHidden(true)
    }
}
