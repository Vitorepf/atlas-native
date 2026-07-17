import SwiftUI

// Motivo section — peel de AutonomosReasonSheet+Form.

extension AutonomosReasonSheet {
    var reasonSection: some View {
        Section(reasonOptional ? "Motivo (opcional no ensaio)" : "Motivo") {
            TextField("Motivo auditável", text: $reason, axis: .vertical).lineLimit(3...6)
                .accessibilityIdentifier(A11yID.autonomosReasonField)
                .accessibilityHint(spokenReasonHint())
        }
    }
}
