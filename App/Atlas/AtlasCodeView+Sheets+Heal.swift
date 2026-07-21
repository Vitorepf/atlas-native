import SwiftUI
import AtlasCore

// Heal receipt sheet — peel de AtlasCodeView+Sheets+Provenance.

extension AtlasCodeSheetsModifier {
  @ViewBuilder
  func healReceiptSheet<Content: View>(on content: Content) -> some View {
    content
      .sheet(isPresented: $showsHealReceipt) {
        if let heal = model.heal {
          AtlasCodeHealReceiptSheet(heal: heal) { Task { await model.undoLastHeal() } }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
      }
  }
}
