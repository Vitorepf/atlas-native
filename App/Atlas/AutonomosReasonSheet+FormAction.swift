import SwiftUI

// Action section — peel de AutonomosReasonSheet+Form.

extension AutonomosReasonSheet {
    var actionSection: some View {
        Section("Ação governada") {
            Text(title)
                .accessibilityAddTraits(.isHeader)
            Text(explainer).font(.footnote).foregroundStyle(.secondary)
        }
    }
}
