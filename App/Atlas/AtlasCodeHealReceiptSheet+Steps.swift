import SwiftUI
import AtlasCore

// Passos do recibo — peel de AtlasCodeHealReceiptSheet (CICLO C).

extension AtlasCodeHealReceiptSheet {
  @ViewBuilder
  func stepsBlock() -> some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(Array(heal.stepReceipts.enumerated()), id: \.element.id) { index, receipt in
        HStack(alignment: .top, spacing: 9) {
          Image(systemName: receipt.status == "completed" ? "checkmark" : "xmark")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(receipt.status == "completed" ? AtlasCodePalette.healed : AtlasCodePalette.alert)
            .padding(.top, 2)
            .accessibilityHidden(true)
          VStack(alignment: .leading, spacing: 2) {
            Text(receipt.action)
              .font(.system(size: 13))
              .foregroundStyle(AtlasTheme.textPrimary)
              .accessibilityHidden(true)
            if !receipt.result.isEmpty {
              Text(receipt.result)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            }
          }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenStepLabel(receipt))
        .accessibilityIdentifier(A11yID.codeHealStep(index))
      }
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
    .accessibilityElement(children: .contain)
    .accessibilityLabel(spokenStepsSummaryLabel())
  }
}
