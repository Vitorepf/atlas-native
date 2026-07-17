import SwiftUI
import AtlasCore

// Enum do filtro de leitura — peel de LiveTimeline+Filters.

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

    func apply(to rows: [NarrativeRow]) -> [NarrativeRow] {
        switch self {
        case .all:
            return rows
        case .intent:
            return rows.filter { $0.style == .intent }
        case .tools:
            return rows.filter { $0.style == .single }
        case .p90:
            return rows.filter(\.isP90)
        }
    }
}
