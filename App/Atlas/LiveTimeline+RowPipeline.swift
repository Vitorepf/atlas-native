import SwiftUI
import AtlasCore

// Filter pipeline — peel de LiveTimeline.

extension LiveTimeline {
    var baseRows: [NarrativeRow] { narrativeRows(from: activities) }
    var rows: [NarrativeRow] { filter.apply(to: baseRows) }
    var showsFilterChips: Bool { baseRows.count > 2 }
    var filterSilence: Bool { showsFilterChips && filter != .all && rows.isEmpty }
}
