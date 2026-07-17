import SwiftUI
import AtlasCore

// Filter apply — peel de LiveTimeline+FilterEnum.

extension TimelineReadFilter {
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
