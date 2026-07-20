import SwiftUI

/// Falha copy — peel de AutonomosView+Failure.

extension AutonomosFleetFailureEmpty {
    var failureCopy: some View {
        Group {
            Text("Catálogo fora de alcance.")
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(message)
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}
