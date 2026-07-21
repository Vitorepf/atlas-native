import SwiftUI
import AtlasCore

// Intent/tools filter — peel de LiveTimeline+FilterApply.

extension TimelineReadFilter {
    func applyStyleFilter(to rows: [NarrativeRow]) -> [NarrativeRow]? {
        switch self {
        case .intent:
            return rows.filter { $0.style == .intent }
        case .tools:
            return rows.filter { $0.style == .single }
        default:
            return nil
        }
    }
}
