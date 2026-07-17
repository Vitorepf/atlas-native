import SwiftUI
import AtlasCore

// Provenance + heal sheets — peel de AtlasCodeView+Sheets.

extension AtlasCodeSheetsModifier {
  @ViewBuilder
  func provenanceAndHealSheets<Content: View>(on content: Content) -> some View {
    content
      .sheet(item: $selectedNode) { node in
        AtlasCodeProvenanceSheet(
          client: session.client,
          repo: model.repo,
          node: node,
          state: model.state(for: node),
          ruleId: model.ruleId(for: node),
          ruleCanon: model.ruleCanon(for: node),
          trunk: model.violations?.trunk,
          phase: provenanceModel.phase,
          onAsk: { onProvenanceAsk(node) }
        )
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $showsHealReceipt) {
        if let heal = model.heal {
          AtlasCodeHealReceiptSheet(heal: heal) { Task { await model.undoLastHeal() } }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
      }
  }
}
