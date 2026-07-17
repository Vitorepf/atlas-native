import SwiftUI
import AtlasCore

// Chips de filtro da timeline — peel de LiveTimeline (régua anti-inchaço).
// Enum → LiveTimeline+FilterEnum.swift

struct TimelineFilterChips: View {
    @Binding var filter: TimelineReadFilter
    var baseRows: [NarrativeRow]
    var reduceMotion: Bool = false
    var filterSilence: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(TimelineReadFilter.allCases) { option in
                let active = option == filter
                let count = option.apply(to: baseRows).count
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                        filter = option
                    }
                } label: {
                    Text(option.label)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textTertiary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.bgRecessed))
                        .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(LiveTimelineA11y.spokenFilterChip(option,
                                                                      count: count,
                                                                      active: active,
                                                                      silent: active && filterSilence))
                .accessibilityHint(LiveTimelineA11y.spokenFilterHint())
                .accessibilityAddTraits(active ? .isSelected : [])
                .accessibilityIdentifier(A11yID.liveTimelineFilter(option.rawValue))
            }
        }
        .padding(.leading, 20)
        .accessibilityIdentifier(A11yID.liveTimelineFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: filter)
    }
}
