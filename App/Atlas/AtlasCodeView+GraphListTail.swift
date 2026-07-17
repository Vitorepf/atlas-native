import SwiftUI
import AtlasCore

// Cauda pagination/mirror/week — peel de AtlasCodeView+GraphList.

extension AtlasCodeView {
    @ViewBuilder
    func graphListTail(graph: AtlasCodeGraphResponse) -> some View {
        if graph.pagination.hasMore {
            Text("\(graph.nodes.count) commits mais recentes — há mais história")
                .font(AtlasFont.serifItalic(12))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 16)
                .accessibilityIdentifier(A11yID.codeGraphTruncated)
        }

        if let mirror = mirrorModel.response {
            AtlasCodeMirrorCard(response: mirror)
                .padding(.top, 22)
        }

        if model.week != nil || model.hasHealReceipt {
            weekSection
                .padding(.top, 22)
        }
    }
}
