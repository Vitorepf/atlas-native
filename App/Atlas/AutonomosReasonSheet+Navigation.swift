import SwiftUI

// A11y shell do reason sheet — peel de AutonomosReasonSheet.

extension AutonomosReasonSheet {
    var reasonNavigation: some View {
        NavigationStack {
            reasonForm
            .navigationTitle("Confirmar ação")
            .toolbar { reasonToolbar }
            .accessibilityIdentifier(A11yID.autonomosReasonSheet)
            .accessibilityLabel(spokenSheetLabel())
            .accessibilityHint(spokenSheetHint())
        }
    }
}
