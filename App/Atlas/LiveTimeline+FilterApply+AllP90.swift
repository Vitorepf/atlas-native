import SwiftUI
import AtlasCore

// All/p90 filter apply — peel de LiveTimeline+FilterApply.

extension TimelineReadFilter {
    func applyAllOrP90(to rows: [NarrativeRow]) -> [NarrativeRow] {
        switch self {
        case .all:
            return rows
        case .p90:
            return rows.filter(\.isP90)
        default:
            return rows
        }
    }
}
