import SwiftUI
import AtlasCore

// WAVE-136 NarrativeRowView chrome peel

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

