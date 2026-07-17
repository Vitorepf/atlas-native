import SwiftUI
import AtlasCore

// Motivo section — peel de AutonomosTransferSheet+Operator.

extension AutonomosTransferSheet {
    @ViewBuilder
    var transferOperatorReasonSection: some View {
        Section("Motivo") {
            TextField("Motivo auditável", text: $reason, axis: .vertical).lineLimit(3...6)
                .accessibilityIdentifier(A11yID.autonomosTransferReason)
                .accessibilityHint("motivo público registrado no ledger")
        }
    }
}
