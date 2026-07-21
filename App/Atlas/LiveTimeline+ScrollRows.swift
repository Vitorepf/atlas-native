import SwiftUI
import AtlasCore

// Timeline rows VStack — peel de LiveTimeline+Scroll.

extension LiveTimeline {
    var timelineRows: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { idx, row in
                NarrativeRowView(row: row,
                                 index: idx,
                                 total: rows.count,
                                 isCurrent: idx == rows.count - 1,
                                 isLast: idx == rows.count - 1,
                                 reduceMotion: reduceMotion)
                    .id(row.id)
                    .transition(reduceMotion ? .opacity
                                : .move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.trailing, 4)
    }
}
