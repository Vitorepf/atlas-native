import SwiftUI
import AtlasCore

// Filtros e worktrees do grafo — peel de AtlasCodeGraphChrome.

extension AtlasCodeView {
    func worktreesSection(_ worktrees: [AtlasCodeWorktree]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WORKTREES")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier(A11yID.codeGraphWorktrees)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(worktrees) { worktree in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(worktree.pathLabel)
                                .font(.system(.caption, weight: .semibold))
                                .foregroundStyle(AtlasTheme.textPrimary)
                                .lineLimit(1)
                            HStack(spacing: 5) {
                                if let branch = worktree.branch?.nonEmpty {
                                    Text(branch)
                                }
                                if let head = worktree.head?.nonEmpty {
                                    Text(String(head.prefix(8)))
                                        .monospacedDigit()
                                }
                                if let state = worktree.state?.nonEmpty {
                                    Text(state)
                                }
                            }
                            .font(AtlasFont.mono(9))
                            .foregroundStyle(AtlasTheme.textTertiary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(AtlasTheme.bgRecessed))
                        .overlay(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
                    }
                }
            }
        }
    }

    func graphStateChips(_ graph: AtlasCodeGraphResponse, filterSilence: Bool) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(AtlasCodeGraphStateFilter.allCases) { option in
                    let active = graphStateFilter == option
                    let count = option.count(in: graph.nodes, model: model)
                    Button {
                        if !reduceMotion {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        }
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                            graphStateFilter = option
                        }
                    } label: {
                        Text("\(option.label) \(count)")
                            .font(AtlasFont.mono(9))
                            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textTertiary)
                            .monospacedDigit()
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface))
                            .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        AtlasCodeGraphA11y.spokenFilterChip(
                            option, count: count, active: active, silent: active && filterSilence
                        )
                    )
                    .accessibilityAddTraits(active ? .isSelected : [])
                    .accessibilityIdentifier(A11yID.codeGraphFilter(option.rawValue))
                }
            }
        }
        .accessibilityIdentifier(A11yID.codeGraphFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: graphStateFilter)
    }
}
