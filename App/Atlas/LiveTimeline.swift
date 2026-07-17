import SwiftUI
import AtlasCore

// A narrativa viva da execução: cada linha espelha um `AtlasAgentActivity`
// real do contrato C5. Sem agregação inventada, sem placeholder quando vazio.
struct LiveTimeline: View {
    let activities: [AtlasAgentActivity]
    let reduceMotion: Bool
    @State private var filter: TimelineReadFilter = .all

    private var baseRows: [NarrativeRow] { narrativeRows(from: activities) }
    private var rows: [NarrativeRow] { filter.apply(to: baseRows) }
    private var showsFilterChips: Bool { baseRows.count > 2 }
    private var filterSilence: Bool { showsFilterChips && filter != .all && rows.isEmpty }

    var body: some View {
        if baseRows.isEmpty {
            EmptyView()
        } else if rows.isEmpty {
            filterSilenceSurface
        } else {
            timelineSurface
        }
    }

    @ViewBuilder
    private var filterSilenceSurface: some View {
        if showsFilterChips {
            TimelineFilterChips(filter: $filter,
                                baseRows: baseRows,
                                reduceMotion: reduceMotion,
                                filterSilence: filterSilence)
                .accessibilityElement(children: .contain)
                .accessibilityLabel(LiveTimelineA11y.spokenFilterSilenceSurface(filter: filter,
                                                                                totalSteps: baseRows.count))
                .accessibilityIdentifier(A11yID.liveTimelineFilterSilence)
        }
    }

    private var timelineSurface: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsFilterChips {
                TimelineFilterChips(filter: $filter,
                                    baseRows: baseRows,
                                    reduceMotion: reduceMotion,
                                    filterSilence: false)
            }
            timelineScroll
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(LiveTimelineA11y.spokenSectionLabel(stepCount: rows.count))
        .accessibilityIdentifier(A11yID.liveTimeline)
    }

    private var timelineScroll: some View {
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
