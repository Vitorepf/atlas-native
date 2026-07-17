import SwiftUI
import AtlasCore

// Heal step row — peel de AtlasCodeHealReceiptSheet+Steps.
// Copy → AtlasCodeHealReceiptSheet+StepCopy.swift

extension AtlasCodeHealReceiptSheet {
  @ViewBuilder
  func stepRow(index: Int, receipt: AtlasCodeHealStepReceipt) -> some View {
    HStack(alignment: .top, spacing: 9) {
      Image(systemName: receipt.status == "completed" ? "checkmark" : "xmark")
        .font(.system(size: 10, weight: .semibold))
        .foregroundStyle(receipt.status == "completed" ? AtlasCodePalette.healed : AtlasCodePalette.alert)
        .padding(.top, 2)
        .accessibilityHidden(true)
      stepCopy(receipt)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(spokenStepLabel(receipt))
    .accessibilityIdentifier(A11yID.codeHealStep(index))
  }
}
