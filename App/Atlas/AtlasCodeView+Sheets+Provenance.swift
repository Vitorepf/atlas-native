import SwiftUI
import AtlasCore

// Provenance + heal sheets — peel de AtlasCodeView+Sheets.
// Heal → AtlasCodeView+Sheets+Heal.swift

extension AtlasCodeSheetsModifier {
  @ViewBuilder
  func provenanceAndHealSheets<Content: View>(on content: Content) -> some View {
    healReceiptSheet(on:
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
    )
  }
}
