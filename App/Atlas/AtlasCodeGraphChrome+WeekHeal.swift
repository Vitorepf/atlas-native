import SwiftUI
import AtlasCore

// Botão recibo de cura — peel de AtlasCodeGraphChrome+Week.
// Label → AtlasCodeGraphChrome+WeekHealLabel.swift

extension AtlasCodeView {
    @ViewBuilder
    var weekHealReceiptButton: some View {
        if model.hasHealReceipt {
            Button { showsHealReceipt = true } label: {
                weekHealReceiptLabel
            }
            .accessibilityIdentifier(A11yID.codeHealReceipt)
            .accessibilityLabel("curado sozinho, ver recibo de cura")
            .accessibilityHint("abre os passos registrados pelo servidor")
        }
    }
}
