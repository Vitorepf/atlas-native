import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: LiveTimeline + FilterChrome fused

// MARK: - Timeline host

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

// MARK: - Filter chrome

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

extension TimelineReadFilter {
    func apply(to rows: [NarrativeRow]) -> [NarrativeRow] {
        if let styled = applyStyleFilter(to: rows) { return styled }
        return applyAllOrP90(to: rows)
    }
}

extension TimelineFilterChips {
    func filterChipA11y<Content: View>(
        _ content: Content,
        option: TimelineReadFilter,
        active: Bool,
        count: Int
    ) -> some View {
        content
            .accessibilityLabel(LiveTimelineFilterJudgment.spokenFilterChip(
                filter: option,
                count: count,
                active: active,
                silent: active && filterSilence
            ))
            .accessibilityHint(LiveTimelineFilterJudgment.filterHint)
            .accessibilityAddTraits(active ? .isSelected : [])
            .accessibilityIdentifier(A11yID.liveTimelineFilter(option.rawValue))
    }
}

extension TimelineFilterChips {
    func filterChipAction(_ option: TimelineReadFilter) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
            filter = option
        }
    }
}

extension TimelineFilterChips {
    func filterChipButton(_ option: TimelineReadFilter, active: Bool, count: Int) -> some View {
        filterChipA11y(
            Button {
                filterChipAction(option)
            } label: {
                chipLabel(option, active: active)
            }
            .buttonStyle(.plain),
            option: option,
            active: active,
            count: count
        )
    }
}

extension TimelineFilterChips {
    func chipLabel(_ option: TimelineReadFilter, active: Bool) -> some View {
        Text(option.label)
            .font(AtlasFont.mono(9))
            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.bgRecessed))
            .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
    }
}

extension TimelineFilterChips {
    @ViewBuilder
    var filterChipLoop: some View {
        ForEach(TimelineReadFilter.allCases) { option in
            let active = option == filter
            let count = option.apply(to: baseRows).count
            filterChipButton(option, active: active, count: count)
        }
    }
}

extension TimelineReadFilter {
    var label: String {
        switch self {
        case .all: return "todos"
        case .intent: return "intenção"
        case .tools: return "ferramentas"
        case .p90: return "p90"
        }
    }
}

enum TimelineReadFilter: String, CaseIterable, Identifiable {
    case all
    case intent
    case tools
    case p90

    var id: String { rawValue }
}

struct TimelineFilterChips: View {
    @Binding var filter: TimelineReadFilter
    var baseRows: [NarrativeRow]
    var reduceMotion: Bool = false
    var filterSilence: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            filterChipLoop
        }
        .padding(.leading, 20)
        .accessibilityIdentifier(A11yID.liveTimelineFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: filter)
    }
}

// MARK: - LiveTimelineFilterJudgment

// MARK: - Types

/// Exclusive timeline read-filter face (WAVE-075) — chrono order sacred.
enum LiveTimelineFilterFace: Equatable {
    /// No filter applied (all).
    case open
    /// Filter selected and has matching steps.
    case active
    /// Filter selected but zero matching steps (silence surface).
    case silent

    var productWord: String {
        switch self {
        case .open: return "open"
        case .active: return "active"
        case .silent: return "silent"
        }
    }

    var spokenFace: String {
        switch self {
        case .open: return "filtro aberto"
        case .active: return "filtro ativo"
        case .silent: return "filtro sem passos"
        }
    }
}

// MARK: - Judgment

/// Pure timeline read-filter grammar — face · spoken · pack.
/// Does **not** reorder narrative (chrono sagrado · WAVE-042/044).
enum LiveTimelineFilterJudgment {

    static let filterHint = "altera quais passos da orquestra são exibidos"

    static func face(
        filter: TimelineReadFilter,
        matchCount: Int,
        isActive: Bool
    ) -> LiveTimelineFilterFace {
        if !isActive || filter == .all {
            return .open
        }
        if matchCount <= 0 { return .silent }
        return .active
    }

    static func spokenSectionLabel(stepCount: Int) -> String {
        "orquestra ao vivo, \(stepCount) passo\(stepCount == 1 ? "" : "s")"
    }

    static func spokenFilterChip(
        filter: TimelineReadFilter,
        count: Int,
        active: Bool,
        silent: Bool
    ) -> String {
        "filtrar timeline por \(filter.label), \(count) passo\(count == 1 ? "" : "s")"
            + spokenFilterChipSuffix(active: active, silent: silent)
    }

    static func spokenFilterChipSuffix(active: Bool, silent: Bool) -> String {
        var suffix = ""
        if active { suffix += ", selecionado" }
        if silent { suffix += ", nenhum passo neste filtro" }
        return suffix
    }

    static func spokenFilterSilenceSurface(
        filter: TimelineReadFilter,
        totalSteps: Int
    ) -> String {
        "orquestra ao vivo, filtro \(filter.label), nenhum dos \(totalSteps) passos corresponde"
    }

    static func spokenRow(
        row: NarrativeRow,
        index: Int,
        total: Int,
        isCurrent: Bool
    ) -> String {
        var parts = ["passo \(index + 1) de \(total)", row.title]
        if let detail = row.detail, !detail.isEmpty { parts.append(detail) }
        if let duration = row.durationMs {
            parts.append("duração \(humanDuration(duration))")
            if row.isP90 { parts.append("acima do p90") }
        }
        if isCurrent { parts.append("passo atual da orquestra") }
        return parts.joined(separator: ", ")
    }

    static func rowValue(index: Int, total: Int, isCurrent: Bool) -> String {
        isCurrent
            ? "passo \(index + 1) de \(total), em andamento"
            : "passo \(index + 1) de \(total)"
    }

    static func packFacts(
        filter: TimelineReadFilter,
        matchCount: Int,
        totalSteps: Int,
        isActive: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(filter: filter, matchCount: matchCount, isActive: isActive)
        facts.append("timeline_filter_face: \(face.productWord)")
        facts.append("timeline_filter: \(filter.rawValue)")
        facts.append("timeline_filter_matches: \(matchCount)")
        facts.append("timeline_steps_total: \(totalSteps)")
        if face == .silent {
            absences.append("filtro sem passos correspondentes")
        }
        return (facts, absences)
    }

    /// WAVE-174: pack honesty for mid-thread — chip filter is @State local to LiveTimeline.
    static func packFactsOpenRecorte(totalSteps: Int) -> (facts: [String], absences: [String]) {
        var pack = packFacts(
            filter: .all,
            matchCount: totalSteps,
            totalSteps: totalSteps,
            isActive: false
        )
        pack.absences.append("filtro de leitura da timeline é local à UI — pack usa recorte aberto")
        return pack
    }
}

// MARK: - LiveTimelineNarrativeJudgment

// MARK: - Types

/// Exclusive live narrative face (WAVE-044). Chrono order stays sacred.
enum LiveTimelineNarrativeFace: Equatable {
    case empty
    case live(Int)
    case filterSilence(filter: TimelineReadFilter, total: Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .live: return "live"
        case .filterSilence: return "filter_silence"
        }
    }

    var kicker: String {
        switch self {
        case .empty: return "Narrativa"
        case .live: return "Narrativa viva"
        case .filterSilence: return "Filtro em silêncio"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem passos de narrativa"
        case .live(let n):
            return n == 1 ? "1 passo na narrativa" : "\(n) passos na narrativa"
        case .filterSilence(let filter, let total):
            return "filtro \(filter.label) em silêncio, \(total) passos na obra completa"
        }
    }
}

// MARK: - Judgment

/// Pure narrative face grammar — never re-ranks rows.
enum LiveTimelineNarrativeJudgment {

    static func face(
        baseRows: [NarrativeRow],
        filteredRows: [NarrativeRow],
        filter: TimelineReadFilter
    ) -> LiveTimelineNarrativeFace {
        if baseRows.isEmpty { return .empty }
        if filteredRows.isEmpty, filter != .all {
            return .filterSilence(filter: filter, total: baseRows.count)
        }
        return .live(filteredRows.count)
    }

    static func summaryLine(
        baseRows: [NarrativeRow],
        filteredRows: [NarrativeRow],
        filter: TimelineReadFilter
    ) -> String {
        switch face(baseRows: baseRows, filteredRows: filteredRows, filter: filter) {
        case .empty:
            return "sem passos"
        case .live(let n):
            let intents = filteredRows.filter { $0.style == .intent }.count
            if filter == .all {
                return intents > 0
                    ? "\(n) passos · \(intents) intenção"
                    : "\(n) passos"
            }
            return "\(filter.label) · \(n) passos"
        case .filterSilence(let filter, let total):
            return "\(filter.label) · 0 de \(total)"
        }
    }

    static func spokenSection(
        baseRows: [NarrativeRow],
        filteredRows: [NarrativeRow],
        filter: TimelineReadFilter
    ) -> String {
        let face = face(baseRows: baseRows, filteredRows: filteredRows, filter: filter)
        switch face {
        case .empty:
            return "narrativa da execução, \(face.spokenFace)"
        case .live:
            return "narrativa da execução, \(face.spokenFace), \(summaryLine(baseRows: baseRows, filteredRows: filteredRows, filter: filter))"
        case .filterSilence:
            return "narrativa da execução, \(face.spokenFace)"
        }
    }

    static func packFacts(
        baseRows: [NarrativeRow],
        filteredRows: [NarrativeRow],
        filter: TimelineReadFilter
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(baseRows: baseRows, filteredRows: filteredRows, filter: filter)
        facts.append("timeline_face: \(face.productWord)")
        facts.append("filter: \(filter.rawValue)")
        facts.append(summaryLine(baseRows: baseRows, filteredRows: filteredRows, filter: filter))
        if baseRows.isEmpty {
            absences.append("sem atividades publicadas na narrativa")
            return (facts, absences)
        }
        facts.append("base_steps: \(baseRows.count)")
        facts.append("filtered_steps: \(filteredRows.count)")
        let intents = baseRows.filter { $0.style == .intent }.count
        facts.append("intent_style: \(intents)")
        if case .filterSilence = face {
            absences.append("filtro \(filter.label) sem linhas — obra ainda tem \(baseRows.count) passos")
        }
        return (facts, absences)
    }

    /// WAVE-174: mid-thread pack from published activities (filter UI is local — open recorte).
    static func packFacts(from activities: [AtlasAgentActivity]) -> (facts: [String], absences: [String]) {
        let base = narrativeRows(from: activities)
        return packFacts(baseRows: base, filteredRows: base, filter: .all)
    }
}

// MARK: - LiveTimelineNarrativeRow

// MARK: - Row

// MARK: - LiveTimelineNarrativeRow

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

// MARK: - LiveTimelineNarrativeRowChrome

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

// MARK: - Row view

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
