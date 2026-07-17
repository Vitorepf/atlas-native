import SwiftUI
import AtlasCore

// Label + status texts — peel de ArtifactSheet+MountCheckRow.

extension ArtifactSheet {
    @ViewBuilder
    func mountCheckRowTexts(check: ArtifactDeliveryCheck) -> some View {
        Text(check.label)
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineLimit(1)
            .accessibilityHidden(true)
        Spacer(minLength: 0)
        Text(check.status)
            .font(AtlasFont.mono(10))
            .foregroundStyle(check.isPassing ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            .accessibilityHidden(true)
    }
}
