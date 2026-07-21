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
