import SwiftUI
import AtlasCore

// Spine frame — gutter multi-lane.

extension AtlasCodeCommitRow {
    @ViewBuilder
    func spineColumnFrame<Content: View>(_ content: Content, motion: Animation?) -> some View {
        content
            .frame(width: AtlasCodeGraphLane.gutter)
            .frame(minHeight: 44)
            .animation(motion, value: state)
            .animation(motion, value: isFirst)
            .animation(motion, value: isLast)
            .atlasCodeGraphSpineDecorative()
    }
}
