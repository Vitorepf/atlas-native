import SwiftUI
import AtlasCore

// Navigation shell — peel de AutonomosTransferSheet.

extension AutonomosTransferSheet {
    var transferNavigationStack: some View {
        NavigationStack {
            transferForm
                .navigationTitle("Transferir missão")
                .toolbar { transferToolbar }
                .accessibilityIdentifier(A11yID.autonomosTransferSheet)
        }
    }
}
