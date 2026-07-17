import SwiftUI
import AtlasCore

// Heal step row — peel de AtlasCodeHealReceiptSheet+Steps.

extension AtlasCodeHealReceiptSheet {
  @ViewBuilder
  func stepRow(index: Int, receipt: AtlasCodeHealStepReceipt) -> some View {
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
