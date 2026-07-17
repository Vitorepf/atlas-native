import SwiftUI
import AtlasCore

// MARK: - Folha: Recibo de Cura (C25 — fato consumado, só veto)
// Conteúdo → AtlasCodeHealReceiptSheet+Content.swift

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
