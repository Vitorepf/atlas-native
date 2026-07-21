import AtlasCore
import SwiftUI

// Cycle 039 fuse → AtlasCodeHealReceiptSheet.swift

// MARK: - Folha: Recibo de Cura (C25 — fato consumado, só veto)

struct AtlasCodeHealReceiptSheet: View {
    let heal: AtlasCodeHealResponse
    let onUndo: () -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            receiptContent()
        }
        .accessibilityIdentifier(A11yID.codeHealReceiptSheet)
        .accessibilityLabel(spokenSheetLabel())
    }
}
