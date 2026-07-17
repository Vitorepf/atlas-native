import SwiftUI
import AtlasCore

extension AtlasCodeView {
    @ViewBuilder
    var content: some View {
        switch model.phase {
        case .idle, .loading:
            TraceEvidenceLoading(text: "lendo a topologia do repositório…", reduceMotion: reduceMotion)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            graphFailure(message)
        case .loaded:
            if let graph = model.graph, !graph.nodes.isEmpty {
                graphContent(graph)
            } else {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel(AtlasCodeGraphA11y.emptyGraph)
            }
        }
    }
}
