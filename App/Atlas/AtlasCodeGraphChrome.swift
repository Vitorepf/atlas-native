import SwiftUI
import AtlasCore

// Chrome do grafo (status, worktrees, filtros, semana/recibo) — extensão de AtlasCodeView.

extension AtlasCodeView {
    // MARK: - Status

    @ViewBuilder
    var statusCapsule: some View {
        if let pulse = statusPulseCopy {
            Text(pulse)
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(statusPulseColor)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 12)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: model.scanState)
                .accessibilityLabel(AtlasCodeGraphA11y.spokenStatus(
                    scanState: model.scanState, headline: pulse
                ))
                .accessibilityIdentifier(A11yID.codeStatus)
        }
    }

    /// Uma voz com o model: `statusHeadline` já fala “sem retorno”.
    var statusPulseCopy: String? {
        switch model.scanState {
        case .violating, .unknown: return model.statusHeadline
        case .clean: return nil
        }
    }

    var statusPulseColor: Color {
        switch model.scanState {
        case .violating: return AtlasCodePalette.alert
        case .unknown: return AtlasTheme.textTertiary
        case .clean: return AtlasTheme.textSecondary
        }
    }

    // MARK: - Worktrees

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
                        worktreeChip(worktree)
                    }
                }
            }
        }
    }

    func worktreeChip(_ worktree: AtlasCodeWorktree) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(worktree.pathLabel)
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
            HStack(spacing: 5) {
                if let branch = worktree.branch?.nonEmpty { Text(branch) }
                if let head = worktree.head?.nonEmpty {
                    Text(String(head.prefix(8))).monospacedDigit()
                }
                if let state = worktree.state?.nonEmpty { Text(state) }
            }
            .font(AtlasFont.mono(9))
            .foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Capsule().fill(AtlasTheme.bgRecessed))
        .overlay(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(worktreeSpokenLabel(worktree))
    }

    private func worktreeSpokenLabel(_ worktree: AtlasCodeWorktree) -> String {
        var parts = [worktree.pathLabel]
        if let branch = worktree.branch?.nonEmpty { parts.append("branch \(branch)") }
        if let state = worktree.state?.nonEmpty { parts.append(state) }
        return parts.joined(separator: ", ")
    }

    // MARK: - Filter chips

    func graphStateChips(_ graph: AtlasCodeGraphResponse, filterSilence: Bool) -> some View {
        HStack(spacing: 0) {
            ForEach(AtlasCodeGraphStateFilter.grafoTabs) { option in
                let active = graphStateFilter == option
                let count = option.count(in: graph.nodes, model: model)
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                        graphStateFilter = option
                    }
                } label: {
                    VStack(spacing: 8) {
                        HStack(spacing: 3) {
                            Text(option.label).atlasSans(11.5, .medium)
                            Text("\(count)").font(AtlasFont.mono(10)).opacity(0.55)
                        }
                        .foregroundStyle(tabForeground(option, active: active))
                        .monospacedDigit()
                        Rectangle()
                            .fill(active ? tabUnderline(option) : Color.clear)
                            .frame(height: 1.5)
                            .shadow(
                                color: active ? tabUnderline(option).opacity(0.35) : .clear,
                                radius: 4, y: 0
                            )
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(.top, 4)
                    .contentShape(Rectangle())
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
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AtlasTheme.separator.opacity(0.85))
                .frame(height: 1)
        }
        .accessibilityIdentifier(A11yID.codeGraphFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: graphStateFilter)
    }

    private func tabForeground(_ option: AtlasCodeGraphStateFilter, active: Bool) -> Color {
        guard active else { return AtlasTheme.textTertiary }
        return option == .violating ? AtlasCodePalette.alert : AtlasTheme.textPrimary
    }

    private func tabUnderline(_ option: AtlasCodeGraphStateFilter) -> Color {
        option == .violating ? AtlasCodePalette.alert : AtlasTheme.accent
    }

    // MARK: - Week

    var weekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let week = model.week {
                weekBody(week)
            }
            if model.hasHealReceipt {
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    showsHealReceipt = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal")
                            .atlasSans(12)
                            .foregroundStyle(AtlasCodePalette.healed)
                            .accessibilityHidden(true)
                        Text("curado sozinho · ver recibo")
                            .font(AtlasFont.serifItalic(13))
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .accessibilityHidden(true)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .atlasSans(10, .semibold)
                            .foregroundStyle(AtlasTheme.textTertiary)
                            .accessibilityHidden(true)
                    }
                    .padding(.vertical, 11)
                    .padding(.horizontal, 13)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                    .background(
                        AtlasCodePalette.healed.opacity(0.07),
                        in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                            .strokeBorder(AtlasCodePalette.healed.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(A11yID.codeHealReceipt)
                .accessibilityLabel("curado sozinho, ver recibo de cura")
                .accessibilityHint("abre os passos registrados pelo servidor")
            }
        }
    }

    @ViewBuilder
    func weekBody(_ week: AtlasCodeWeek) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("A semana")
                    .font(AtlasFont.serif(18, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                Spacer()
                Text(week.window)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            if AtlasCodeWeekUI.isQuiet(week) {
                Text("semana quieta · sem commits nem curas")
                    .font(AtlasFont.serifItalic(13))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityHidden(true)
            } else {
                HStack(spacing: 18) {
                    if week.commits > 0 { weekMetric("commits", value: week.commits) }
                    if week.heals > 0 { weekMetric("curas", value: week.heals) }
                    if week.prevented > 0 { weekMetric("prevenidas", value: week.prevented) }
                }
                .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AtlasCodeWeekUI.spokenLabel(week))
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier(A11yID.codeWeek)
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.28),
            value: AtlasCodeWeekUI.weekPhaseID(week)
        )
    }

    func weekMetric(_ label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(String(value))
                .font(AtlasFont.serif(21, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .monospacedDigit()
            Text(label)
                .atlasSans(10)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}

// MARK: - State filter

enum AtlasCodeGraphStateFilter: String, CaseIterable, Identifiable {
    case all
    case onMain
    case violating
    case healed
    case history

    var id: String { rawValue }

    /// Tabs do grafo AX — sem “história” (ruído; o scroll já é história).
    static let grafoTabs: [AtlasCodeGraphStateFilter] = [.all, .onMain, .violating, .healed]

    var label: String {
        switch self {
        case .all: return "todos"
        case .onMain: return "main"
        case .violating: return "fora"
        case .healed: return "curados"
        case .history: return "história"
        }
    }

    var targetState: AtlasCodeNodeState {
        switch self {
        case .onMain: return .onMain
        case .healed: return .healed
        case .violating: return .violating
        case .all, .history: return .history
        }
    }

    @MainActor
    func nodes(in nodes: [AtlasCodeGraphNode], model: AtlasCodeModel) -> [AtlasCodeGraphNode] {
        guard self != .all else { return nodes }
        let target = targetState
        return nodes.filter { model.state(for: $0) == target }
    }

    @MainActor
    func count(in nodes: [AtlasCodeGraphNode], model: AtlasCodeModel) -> Int {
        self == .all ? nodes.count : self.nodes(in: nodes, model: model).count
    }
}
