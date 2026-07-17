import SwiftUI
import AtlasCore

// MARK: - Folha: Recibo de Cura (C25 — fato consumado, só veto)

struct AtlasCodeHealReceiptSheet: View {
    let heal: AtlasCodeHealResponse
    let onUndo: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 7) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                    Text("CURADO SOZINHO · \(heal.mode.uppercased())")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.2)
                }
                .foregroundStyle(AtlasCodePalette.healed)

                Text("você não foi necessário")
                    .font(AtlasFont.serif(20, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(heal.stepReceipts) { receipt in
                        HStack(alignment: .top, spacing: 9) {
                            Image(systemName: receipt.status == "completed" ? "checkmark" : "xmark")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(receipt.status == "completed" ? AtlasCodePalette.healed : AtlasCodePalette.alert)
                                .padding(.top, 2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(receipt.action)
                                    .font(.system(size: 13))
                                    .foregroundStyle(AtlasTheme.textPrimary)
                                Text(receipt.result)
                                    .font(AtlasFont.mono(9))
                                    .foregroundStyle(AtlasTheme.textTertiary)
                            }
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))

                // Único verbo humano em plumbing: veto retroativo com recibo.
                if let note = AtlasCodeUndoWindow.note(expiresAt: heal.stepReceipts.first?.undoExpiresAt) {
                    Text(note)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityIdentifier(A11yID.codeHealUndoWindow)
                }
                if heal.healId != nil, AtlasCodeUndoWindow.isOpen(expiresAt: heal.stepReceipts.first?.undoExpiresAt) {
                    Button {
                        onUndo()
                        dismiss()
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "arrow.uturn.backward")
                            Text("Desfazer — com recibo")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .atlasCard(cornerRadius: 13)
                    }
                    .accessibilityIdentifier(A11yID.codeHealUndo)
                }
                Spacer(minLength: 0)
            }
            .padding(22)
        }
    }
}
