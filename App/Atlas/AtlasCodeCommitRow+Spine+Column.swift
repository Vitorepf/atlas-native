import SwiftUI
import AtlasCore

// Spine column — peel de AtlasCodeCommitRow+Spine.

extension AtlasCodeCommitRow {
    @ViewBuilder
    func spineColumn(spineTint: Color, motion: Animation?) -> some View {
        VStack(spacing: 0) {
            spineConnector(fill: isFirst ? .clear : spineTint)
                .frame(height: 8)
            spineNode(motion: motion)
            spineConnector(fill: isLast ? .clear : spineTint)
                .frame(maxHeight: .infinity)
        }
        .frame(width: 22)
        .animation(motion, value: state)
        .animation(motion, value: isFirst)
        .animation(motion, value: isLast)
        .atlasCodeGraphSpineDecorative()
    }
}
