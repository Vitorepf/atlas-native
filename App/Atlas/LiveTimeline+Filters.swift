import SwiftUI
import AtlasCore

// Chips + filtro de leitura da timeline — peel de LiveTimeline (régua anti-inchaço).

enum TimelineReadFilter: String, CaseIterable, Identifiable {
    case all
    case intent
    case tools
    case p90

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "todos"
        case .intent: return "intenção"
        case .tools: return "ferramentas"
        case .p90: return "p90"
        }
    }

    func apply(to rows: [NarrativeRow]) -> [NarrativeRow] {
        switch self {
        case .all:
            return rows
        case .intent:
            return rows.filter { $0.style == .intent }
        case .tools:
            return rows.filter { $0.style == .single }
        case .p90:
            return rows.filter(\.isP90)
        }
    }
}

struct TimelineFilterChips: View {
    @Binding var filter: TimelineReadFilter
    var reduceMotion: Bool = false
    var filterSilence: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(TimelineReadFilter.allCases) { option in
                let active = option == filter
                Button {
                    if !reduceMotion {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    }
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
                                                                      active: active,
                                                                      silent: active && filterSilence))
                .accessibilityAddTraits(active ? .isSelected : [])
            }
        }
        .padding(.leading, 20)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: filter)
    }
}
