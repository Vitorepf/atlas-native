import SwiftUI
import AtlasCore

// Presentation chrome — peel de AutonomosDetailSheet.

extension AutonomosPublicDetailSheet {
    var detailPresentation: some View {
        NavigationStack {
            detailScrollBody
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(AtlasTheme.bg)
        .accessibilityIdentifier(A11yID.autonomosDetailSheet)
        .accessibilityLabel(spokenSheetLabel(backlog: backlog))
        .accessibilityHint(spokenSheetHint())
    }
}
