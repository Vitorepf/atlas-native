import SwiftUI
import AtlasCore

// Graph filter predicates — peel de AtlasCodeGraphStateFilter.
// TargetState → AtlasCodeGraphStateFilter+Nodes+TargetState.swift

extension AtlasCodeGraphStateFilter {
    @MainActor
    func nodes(in nodes: [AtlasCodeGraphNode], model: AtlasCodeModel) -> [AtlasCodeGraphNode] {
        guard self != .all else { return nodes }
        let target = targetState
        return nodes.filter { model.state(for: $0) == target }
    }

    @MainActor
    func count(in nodes: [AtlasCodeGraphNode], model: AtlasCodeModel) -> Int {
        self == .all ? nodes.count : self.nodes(in: nodes, model: model).count
    }
}
