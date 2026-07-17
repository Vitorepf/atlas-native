import SwiftUI
import AtlasCore

// Scroll da timeline — peel de LiveTimeline+Surfaces.

extension LiveTimeline {
    var timelineScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
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
            .frame(maxHeight: min(CGFloat(rows.count) * 34 + 12, 232))
            .scrollIndicators(.hidden)
            .onChange(of: rows.count) {
                guard let last = rows.last?.id else { return }
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                    proxy.scrollTo(last, anchor: .bottom)
                }
            }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: rows.count)
        }
    }
}
