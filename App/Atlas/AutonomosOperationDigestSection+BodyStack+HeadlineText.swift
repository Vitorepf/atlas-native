import SwiftUI
import AtlasCore

// Headline copy — peel de AutonomosOperationDigestSection+BodyStack.

extension AutonomosOperationDigestSection {
    var digestSignalHeadlineText: some View {
        Text(AutonomosOperationDigestA11y.displayHeadline(
            delivered: deliveredTotal, pending: pendingCount, incident: incidentPresent))
            .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityHidden(true)
    }
}
