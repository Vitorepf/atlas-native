import Foundation

// LiveTimeline surface A11yIDs — peel de A11yID+Surfaces.

extension A11yID {
    static let liveTimeline = "live-timeline"
    static let liveTimelineFilters = "live-timeline-filters"
    static let liveTimelineFilterSilence = "live-timeline-filter-silence"
    static let liveTimelineFilterPrefix = "live-timeline-filter-"
    static func liveTimelineFilter(_ raw: String) -> String { liveTimelineFilterPrefix + raw }
}
