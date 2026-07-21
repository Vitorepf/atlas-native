import AtlasCore
import SwiftUI

// WAVE-075: filter/list a11y → LiveTimelineFilterJudgment (chrono sagrado)

enum LiveTimelineA11y {
    static func spokenSectionLabel(stepCount: Int) -> String {
        LiveTimelineFilterJudgment.spokenSectionLabel(stepCount: stepCount)
    }

    static func spokenFilterChip(
        _ filter: TimelineReadFilter,
        count: Int,
        active: Bool,
        silent: Bool
    ) -> String {
        LiveTimelineFilterJudgment.spokenFilterChip(
            filter: filter, count: count, active: active, silent: silent
        )
    }

    static func spokenFilterHint() -> String {
        LiveTimelineFilterJudgment.filterHint
    }

    static func spokenRow(
        row: NarrativeRow,
        index: Int,
        total: Int,
        isCurrent: Bool
    ) -> String {
        LiveTimelineFilterJudgment.spokenRow(
            row: row, index: index, total: total, isCurrent: isCurrent
        )
    }

    static func rowValue(index: Int, total: Int, isCurrent: Bool) -> String {
        LiveTimelineFilterJudgment.rowValue(index: index, total: total, isCurrent: isCurrent)
    }

    static func spokenFilterSilenceSurface(
        filter: TimelineReadFilter,
        totalSteps: Int
    ) -> String {
        LiveTimelineFilterJudgment.spokenFilterSilenceSurface(
            filter: filter, totalSteps: totalSteps
        )
    }
}

func activityIconIntent(_ kind: AtlasAgentActivity.Kind) -> String? {
    switch kind {
    case .understanding: return "text.magnifyingglass"
    case .context: return "square.stack.3d.up"
    case .planning: return "list.bullet.rectangle"
    case .permission: return "lock.shield"
    case .reasoning: return "brain"
    default: return nil
    }
}

func activityIconTerminal(_ kind: AtlasAgentActivity.Kind) -> String? {
    switch kind {
    case .completed: return "checkmark.circle.fill"
    case .warning: return "exclamationmark.triangle.fill"
    case .progress: return "ellipsis.circle"
    default: return nil
    }
}

func activityIconTool(_ kind: AtlasAgentActivity.Kind) -> String? {
    switch kind {
    case .executing: return "chevron.left.forwardslash.chevron.right"
    case .reading: return "doc.text"
    case .editing: return "pencil.line"
    case .verifying: return "checkmark.seal"
    case .evidence: return "tray.full"
    default: return nil
    }
}

func activityIcon(_ kind: AtlasAgentActivity.Kind) -> String {
    activityIconIntent(kind)
        ?? activityIconTool(kind)
        ?? activityIconTerminal(kind)
        ?? "ellipsis.circle"
}


extension NarrativeRowView {
    var narrativeA11y: some View {
        narrativeBody
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(LiveTimelineA11y.spokenRow(row: row,
                                                           index: index,
                                                           total: total,
                                                           isCurrent: isCurrent))
            .accessibilityValue(LiveTimelineA11y.rowValue(index: index, total: total, isCurrent: isCurrent))
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
            .accessibilityLabel(LiveTimelineA11y.spokenFilterSilenceSurface(filter: filter,
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

extension LiveTimeline {
    @ViewBuilder
    var filterSilenceSurface: some View {
        if showsFilterChips {
            VStack(alignment: .leading, spacing: 8) {
                narrativeFaceChrome
                filterSilenceA11y(
                    TimelineFilterChips(filter: $filter,
                                        baseRows: baseRows,
                                        reduceMotion: reduceMotion,
                                        filterSilence: filterSilence)
                )
            }
        }
    }
}

extension LiveTimeline {
    var timelineSurface: some View {
        VStack(alignment: .leading, spacing: 8) {
            narrativeFaceChrome
            if showsFilterChips {
                TimelineFilterChips(filter: $filter,
                                    baseRows: baseRows,
                                    reduceMotion: reduceMotion,
                                    filterSilence: false)
            }
            timelineScroll
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            LiveTimelineNarrativeJudgment.spokenSection(
                baseRows: baseRows,
                filteredRows: rows,
                filter: filter
            )
        )
        .accessibilityIdentifier(A11yID.liveTimeline)
    }
}

struct LiveTimeline: View {
    let activities: [AtlasAgentActivity]
    let reduceMotion: Bool
    @State var filter: TimelineReadFilter = .all

    var body: some View {
        timelineBody
    }
}

func annotateNarrativeDurations(_ rows: inout [NarrativeRow]) {
    guard rows.count > 1 else { return }
    for index in rows.indices.dropLast() {
        guard let start = rows[index].occurredAt,
              let end = rows[rows.index(after: index)].occurredAt else { continue }
        rows[index].durationMs = max(0, Int(end.timeIntervalSince(start) * 1000))
    }
    annotateNarrativeP90(&rows)
}

func isNarrativeIntentKind(_ kind: AtlasAgentActivity.Kind) -> Bool {
    [.understanding, .planning, .reasoning, .permission,
     .completed, .warning, .evidence, .verifying].contains(kind)
}

func annotateNarrativeP90(_ rows: inout [NarrativeRow]) {
    let durations = rows.compactMap(\.durationMs).sorted()
    guard !durations.isEmpty else { return }
    let p90Index = min(durations.count - 1, Int(ceil(Double(durations.count) * 0.9)) - 1)
    let threshold = durations[max(0, p90Index)]
    guard threshold > 0 else { return }
    for index in rows.indices {
        rows[index].isP90 = (rows[index].durationMs ?? 0) >= threshold
    }
}

extension LiveTimeline {
    @ViewBuilder
    var timelineBody: some View {
        if baseRows.isEmpty {
            EmptyView()
        } else if rows.isEmpty {
            filterSilenceSurface
        } else {
            timelineSurface
        }
    }
}

extension NarrativeRowView {
    var narrativeBody: some View {
        HStack(alignment: .top, spacing: 10) {
            narrativeSpine
            narrativeTextStack
            Spacer(minLength: 0)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDetailLine: some View {
        if let detail = row.detail, !detail.isEmpty {
            Text(detail).font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(row.style == .intent ? 2 : 1)
                .truncationMode(.middle)
                .accessibilityHidden(true)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeP90Badge: some View {
        if row.isP90 {
            Text("p90")
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.domOperacional)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDurationChip: some View {
        if let duration = row.durationMs {
            HStack(spacing: 5) {
                Text("Δ \(humanDuration(duration))")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(row.isP90 ? AtlasTheme.domOperacional : AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                narrativeP90Badge
            }
            .accessibilityHidden(true)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDurationMeta: some View {
        narrativeDurationChip
    }
}

extension NarrativeRowView {
    func narrativePulseLifecycle() -> some View {
        narrativeA11y
            .onAppear {
                if isCurrent && !reduceMotion {
                    withAnimation(AtlasMotion.breath(0.9)) { pulse = true }
                }
            }
            .onChange(of: isCurrent) { _, now in if !now { pulse = false } }
    }
}

struct NarrativeRow: Identifiable, Equatable {
    enum Style { case intent, single }
    let id: String
    let style: Style
    let title: String
    let detail: String?
    let occurredAt: Date?
    var durationMs: Int? = nil
    var isP90: Bool = false
}

extension NarrativeRowView {
    var narrativeSpine: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(isCurrent ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.4))
                .frame(width: 7, height: 7)
                .opacity(isCurrent && pulse && !reduceMotion ? 0.4 : 1)
                .padding(.top, 5)
            if !isLast {
                Rectangle()
                    .fill(AtlasTheme.accent.opacity(0.22))
                    .frame(width: 1.5)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 10)
        .accessibilityHidden(true)
    }
}

extension NarrativeRowView {
    var narrativeTextStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(row.title)
                .font(row.style == .intent ? .system(.footnote) : .system(.caption))
                .foregroundStyle(row.style == .intent
                    ? (isCurrent ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
                    : AtlasTheme.textTertiary)
                .lineLimit(row.style == .intent ? 3 : 2)
                .accessibilityHidden(true)
            narrativeDetailLine
            narrativeDurationMeta
        }
        .padding(.bottom, 10)
    }
}

extension NarrativeRowView {
    var currentTraits: AccessibilityTraits {
        guard isCurrent else { return [] }
        return reduceMotion ? .isSelected : [.isSelected, .updatesFrequently]
    }
}

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
