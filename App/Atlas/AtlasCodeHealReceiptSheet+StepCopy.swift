import SwiftUI
import AtlasCore

// Heal step copy column — peel de AtlasCodeHealReceiptSheet+StepRow.

extension AtlasCodeHealReceiptSheet {
  @ViewBuilder
  func stepCopy(_ receipt: AtlasCodeHealStepReceipt) -> some View {
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
}
