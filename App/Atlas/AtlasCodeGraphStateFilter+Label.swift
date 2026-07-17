import SwiftUI
import AtlasCore

// Graph filter labels — peel de AtlasCodeGraphStateFilter.

extension AtlasCodeGraphStateFilter {
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
