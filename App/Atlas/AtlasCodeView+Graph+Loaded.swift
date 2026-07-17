import SwiftUI
import AtlasCore

// Graph loaded content — peel de AtlasCodeView+Graph.

extension AtlasCodeView {
    @ViewBuilder
    var graphLoadedContent: some View {
        if let graph = model.graph, !graph.nodes.isEmpty {
            graphContent(graph)
        } else {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel(AtlasCodeGraphA11y.emptyGraph)
        }
    }
}
