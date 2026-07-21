import SwiftUI
import AtlasCore

// Passos do recibo — peel de AtlasCodeHealReceiptSheet (CICLO C).
// Row → AtlasCodeHealReceiptSheet+StepRow.swift

extension AtlasCodeHealReceiptSheet {
  @ViewBuilder
  func stepsBlock() -> some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(Array(heal.stepReceipts.enumerated()), id: \.element.id) { index, receipt in
        stepRow(index: index, receipt: receipt)
      }
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
    .accessibilityElement(children: .contain)
    .accessibilityLabel(spokenStepsSummaryLabel())
  }
}
