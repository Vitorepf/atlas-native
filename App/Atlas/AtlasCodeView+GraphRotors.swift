import SwiftUI
import AtlasCore

// Graph rotor helpers — peel de AtlasCodeView.
// Rotors → AtlasCodeView+GraphRotorsA11y.swift

extension AtlasCodeView {
    func nodes(in graph: AtlasCodeGraphResponse, matching state: AtlasCodeNodeState) -> [AtlasCodeGraphNode] {
        graph.nodes.filter { model.state(for: $0) == state }
    }

    func rotorLabel(for node: AtlasCodeGraphNode) -> String {
        node.message ?? String(node.hash.prefix(8))
    }

    func openWhyBiographyIfAvailable(for node: AtlasCodeGraphNode) async {
        await provenanceModel.load(hash: node.hash)
        guard case .loaded(let provenance) = provenanceModel.phase,
              let path = provenance.files.first?.path else { return }
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        whyFileTarget = WhyFileTarget(path: path)
    }
}
