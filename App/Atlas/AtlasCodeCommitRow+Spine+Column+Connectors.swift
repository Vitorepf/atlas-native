import SwiftUI
import AtlasCore

// Spine connectors — peel de AtlasCodeCommitRow+Spine+Column.

extension AtlasCodeCommitRow {
    @ViewBuilder
    func spineColumnConnectors(spineTint: Color, motion: Animation?) -> some View {
        VStack(spacing: 0) {
            spineConnector(fill: isFirst ? .clear : spineTint)
                .frame(height: 8)
            spineNode(motion: motion)
            spineConnector(fill: isLast ? .clear : spineTint)
                .frame(maxHeight: .infinity)
        }
    }
}
