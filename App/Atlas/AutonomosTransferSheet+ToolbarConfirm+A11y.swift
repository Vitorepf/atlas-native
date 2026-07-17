import SwiftUI
import AtlasCore

// Confirm a11y — peel de AutonomosTransferSheet+ToolbarConfirm.

extension AutonomosTransferSheet {
    func transferConfirmA11y<V: View>(_ button: V) -> some View {
        button
            .accessibilityIdentifier(A11yID.autonomosTransferSubmit)
            .accessibilityLabel(AutonomosTransferSheetA11yConfirm.spokenConfirm(canConfirm: canConfirm))
            .accessibilityHint(
                AutonomosTransferSheetA11yConfirm.spokenConfirmHint(
                    canConfirm: canConfirm,
                    hasPlacement: hasPlacement
                )
            )
    }
}
