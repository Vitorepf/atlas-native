import SwiftUI
import AtlasCore

// Card chrome — peel de ExecutionRibbon.

extension ExecutionRibbon {
    func executionRibbonCard<V: View>(_ content: V) -> some View {
        content
            .padding(.vertical, 10).padding(.horizontal, 14)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control, fillOpacity: 0.5)
    }
}
