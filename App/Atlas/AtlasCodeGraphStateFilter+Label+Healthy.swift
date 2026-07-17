import SwiftUI
import AtlasCore

// Healthy graph filter labels — peel de AtlasCodeGraphStateFilter+Label.

extension AtlasCodeGraphStateFilter {
    var labelHealthy: String? {
        switch self {
        case .all: return "todos"
        case .onMain: return "trunk"
        case .healed: return "curados"
        default: return nil
        }
    }
}
