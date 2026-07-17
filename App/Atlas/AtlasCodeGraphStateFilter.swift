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
}
