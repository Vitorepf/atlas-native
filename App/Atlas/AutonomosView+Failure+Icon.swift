import SwiftUI

// Failure icon — peel de AutonomosView+Failure.

extension AutonomosFleetFailureEmpty {
    var failureIcon: some View {
        Image(systemName: "exclamationmark.triangle")
            .font(AtlasFont.serif(22))
            .foregroundStyle(AtlasTheme.domOperacional)
            .accessibilityHidden(true)
    }
}
