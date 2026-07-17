import SwiftUI
import AtlasCore

// Graph filter labels — peel de AtlasCodeGraphStateFilter.
// Healthy → AtlasCodeGraphStateFilter+Label+Healthy.swift

extension AtlasCodeGraphStateFilter {
    var label: String {
        if let healthy = labelHealthy { return healthy }
        switch self {
        case .violating: return "desvios"
        case .history: return "história"
        default: return "todos"
        }
    }
}
