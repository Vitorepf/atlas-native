import SwiftUI
import AtlasCore

// Provenance sheet bind — peel de AtlasCodeView+Sheets+Provenance.

extension AtlasCodeSheetsModifier {
    @ViewBuilder
    func provenanceSheetBind<Content: View>(on content: Content) -> some View {
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
    }
}
