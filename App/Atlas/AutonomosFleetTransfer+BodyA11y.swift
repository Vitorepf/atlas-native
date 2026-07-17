import SwiftUI
import AtlasCore

// A11y traits — peel de AutonomosFleetTransfer+Body.

extension AutonomosTransferStatus {
    func transferBodyA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(transfer.transferSpokenSummary)
            .accessibilityAddTraits(transfer.isHandoffInFlight ? .updatesFrequently : [])
    }
}
