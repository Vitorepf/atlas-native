import SwiftUI
import AtlasCore

enum AtlasCodeGraphStateFilter: String, CaseIterable, Identifiable {
    case all
    case onMain
    case violating
    case healed
    case history

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "todos"
        case .onMain: return "trunk"
        case .violating: return "desvios"
        case .healed: return "curados"
        case .history: return "história"
        }
    }

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

    private var targetState: AtlasCodeNodeState {
        switch self {
        case .all, .history: return .history
        case .onMain: return .onMain
        case .violating: return .violating
        case .healed: return .healed
        }
    }
}
