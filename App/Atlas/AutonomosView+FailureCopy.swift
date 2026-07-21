import SwiftUI

/// Falha copy — peel de AutonomosView+Failure.

extension AutonomosFleetFailureEmpty {
    var failureCopy: some View {
        Group {
            Text("Catálogo fora de alcance.")
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(message)
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
