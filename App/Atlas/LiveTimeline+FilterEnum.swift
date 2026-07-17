import SwiftUI
import AtlasCore

// Enum do filtro de leitura — peel de LiveTimeline+Filters.
// Apply → LiveTimeline+FilterApply.swift

enum TimelineReadFilter: String, CaseIterable, Identifiable {
    case all
    case intent
    case tools
    case p90

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "todos"
        case .intent: return "intenção"
        case .tools: return "ferramentas"
        case .p90: return "p90"
        }
    }
}
