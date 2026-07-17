import SwiftUI
import AtlasCore

// Chrome do grafo (status, worktrees, filtros, semana/recibo) — peel de
// AtlasCodeView+Graph. A lista de commits e a pílula ficam no Graph.

extension AtlasCodeView {
    func worktreesSection(_ worktrees: [AtlasCodeWorktree]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WORKTREES")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.textTertiary)
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

    func graphStateChips(_ graph: AtlasCodeGraphResponse) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(AtlasCodeGraphStateFilter.allCases) { option in
                    let active = graphStateFilter == option
                    Button {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        graphStateFilter = option
                    } label: {
                        Text("\(option.label) \(option.count(in: graph.nodes, model: model))")
                            .font(AtlasFont.mono(9))
                            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textTertiary)
                            .monospacedDigit()
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface))
                            .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("filtrar grafo por \(option.label)")
                }
            }
        }
    }

    /// Cápsula central e simétrica: a única voz do estado geral.
    var statusCapsule: some View {
        let cor: Color = {
            switch model.scanState {
            case .violating: return AtlasCodePalette.alert
            case .clean: return AtlasCodePalette.healed
            case .unknown: return AtlasTheme.textTertiary
            }
        }()
        let simbolo: String = {
            switch model.scanState {
            case .violating: return "exclamationmark.triangle"
            case .clean: return "checkmark"
            case .unknown: return "questionmark"
            }
        }()

        return HStack(spacing: 7) {
            Image(systemName: simbolo)
                .font(.system(size: 10, weight: .semibold))
            Text(model.statusHeadline)
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
        }
        .foregroundStyle(cor)
        .padding(.horizontal, 15)
        .padding(.vertical, 7)
        .background(Capsule().fill(cor.opacity(0.09)))
        .overlay(Capsule().strokeBorder(cor.opacity(0.35), lineWidth: 1))
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: model.scanState)
        .accessibilityLabel(model.statusHeadline)
        .accessibilityIdentifier(A11yID.codeStatus)
    }

    /// A semana + o recibo da noite: fatos consumados, nunca pedidos.
    var weekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let week = model.week {
                HStack(alignment: .firstTextBaseline) {
                    Text("A semana")
                        .font(AtlasFont.serif(18, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Spacer()
                    Text(week.window)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                HStack(spacing: 18) {
                    weekMetric("commits", value: week.commits)
                    weekMetric("curas", value: week.heals)
                    weekMetric("prevenidas", value: week.prevented)
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("A semana: \(week.commits) commits, \(week.heals) curas, \(week.prevented) prevenidas")
            }

            if model.hasHealReceipt {
                Button { showsHealReceipt = true } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal")
                            .font(.system(size: 12))
                            .foregroundStyle(AtlasCodePalette.healed)
                        Text("curado sozinho · ver recibo")
                            .font(AtlasFont.serifItalic(13))
                            .foregroundStyle(AtlasTheme.textSecondary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .padding(.vertical, 11)
                    .padding(.horizontal, 13)
                    .background(AtlasCodePalette.healed.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(AtlasCodePalette.healed.opacity(0.3), lineWidth: 1)
                    )
                }
                .accessibilityIdentifier(A11yID.codeHealReceipt)
            }
        }
    }

    func weekMetric(_ label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(String(value))
                .font(AtlasFont.serif(21, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}
