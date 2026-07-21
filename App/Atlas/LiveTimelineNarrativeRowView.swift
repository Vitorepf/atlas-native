import SwiftUI
import AtlasCore

// WAVE-117 narrative row view

struct NarrativeRowView: View {
    let row: NarrativeRow
    let index: Int
    let total: Int
    let isCurrent: Bool
    let isLast: Bool
    let reduceMotion: Bool
    @State var pulse = false

    var body: some View {
        narrativePulseLifecycle()
    }
}

extension LiveTimeline {
    var baseRows: [NarrativeRow] { narrativeRows(from: activities) }
    var rows: [NarrativeRow] { filter.apply(to: baseRows) }
    var showsFilterChips: Bool { baseRows.count > 2 }
    var filterSilence: Bool { showsFilterChips && filter != .all && rows.isEmpty }
}

func narrativeRowMap(from activities: [AtlasAgentActivity]) -> [NarrativeRow] {
    activities.map { activity in
        NarrativeRow(
            id: activity.id,
            style: isNarrativeIntentKind(activity.kind) ? .intent : .single,
            title: activity.title,
            detail: activity.detail,
            occurredAt: AtlasTime.date(activity.occurredAt)
        )
    }
}

func narrativeRows(from activities: [AtlasAgentActivity]) -> [NarrativeRow] {
    var rows = narrativeRowMap(from: activities)
    annotateNarrativeDurations(&rows)
    return rows
}

// WAVE-136 NarrativeRowView peels from LiveTimeline host
extension NarrativeRowView {
    var narrativeA11y: some View {
        narrativeBody
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(LiveTimelineFilterJudgment.spokenRow(row: row,
                                                           index: index,
                                                           total: total,
                                                           isCurrent: isCurrent))
            .accessibilityValue(LiveTimelineFilterJudgment.rowValue(index: index, total: total, isCurrent: isCurrent))
            .accessibilityAddTraits(currentTraits)
    }
}

extension LiveTimeline {
    func timelineScrollToLast(_ proxy: ScrollViewProxy) {
        guard let last = rows.last?.id else { return }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            proxy.scrollTo(last, anchor: .bottom)
        }
    }
}

extension LiveTimeline {
    var timelineScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                timelineRows
            }
            .frame(maxHeight: min(CGFloat(rows.count) * 34 + 12, 232))
            .scrollIndicators(.hidden)
            .onChange(of: rows.count) { timelineScrollToLast(proxy) }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: rows.count)
        }
    }
}

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

extension LiveTimeline {
    func filterSilenceA11y<V: View>(_ content: V) -> some View {
        content
            .accessibilityElement(children: .contain)
            .accessibilityLabel(LiveTimelineFilterJudgment.spokenFilterSilenceSurface(filter: filter,
                                                                            totalSteps: baseRows.count))
            .accessibilityValue(
                LiveTimelineFilterJudgment.face(
                    filter: filter,
                    matchCount: rows.count,
                    isActive: true
                ).productWord
            )
            .accessibilityIdentifier(A11yID.liveTimelineFilterSilence)
    }
}

extension LiveTimeline {
    /// WAVE-044: exclusive narrative face (chrono order unchanged).
    var narrativeFace: LiveTimelineNarrativeFace {
        LiveTimelineNarrativeJudgment.face(
            baseRows: baseRows,
            filteredRows: rows,
            filter: filter
        )
    }

    @ViewBuilder
    var narrativeFaceChrome: some View {
        switch narrativeFace {
        case .empty:
            EmptyView()
        case .live, .filterSilence:
            HStack(spacing: 6) {
                Text(narrativeFace.kicker)
                    .font(AtlasFont.mono(9))
                    .tracking(0.7)
                    .foregroundStyle(
                        narrativeFace.productWord == "filter_silence"
                            ? AtlasTheme.textTertiary
                            : AtlasTheme.accent
                    )
                Text(LiveTimelineNarrativeJudgment.summaryLine(
                    baseRows: baseRows,
                    filteredRows: rows,
                    filter: filter
                ))
                .font(AtlasFont.serif(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                Spacer(minLength: 0)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(narrativeFace.spokenFace)
            .accessibilityIdentifier(A11yID.liveTimelineFace)
        }
    }
}

