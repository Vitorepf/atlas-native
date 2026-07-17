import SwiftUI
import AtlasCore

extension AtlasCodeView {
    @ViewBuilder
    var content: some View {
        switch model.phase {
        case .idle, .loading:
            VStack(spacing: 12) {
                ProgressView().tint(AtlasTheme.accent)
                Text("lendo a topologia do repositório…")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            VStack(spacing: 14) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 24))
                    .foregroundStyle(AtlasCodePalette.alert)
                Text("não consegui ler este repositório")
                    .font(AtlasFont.serif(20, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(message)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                Button("Tentar de novo") { Task { await model.load() } }
                    .buttonStyle(.borderedProminent)
                    .tint(AtlasTheme.accent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            if let graph = model.graph, !graph.nodes.isEmpty {
                graphContent(graph)
            } else {
                Text("nenhum commit para mostrar")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    func graphContent(_ graph: AtlasCodeGraphResponse) -> some View {
        let filteredNodes = graphStateFilter.nodes(in: graph.nodes, model: model)
        return ScrollView {
            // F2.9: LazyVStack — não materializa ~200 rows + dims de uma vez.
            LazyVStack(alignment: .leading, spacing: 0) {
                statusCapsule
                    .padding(.bottom, 14)

                if !graph.worktrees.isEmpty {
                    worktreesSection(graph.worktrees)
                        .padding(.bottom, 14)
                }

                graphStateChips(graph)
                    .padding(.bottom, 10)

                if filteredNodes.isEmpty {
                    Text("nenhum commit neste filtro")
                        .font(AtlasFont.serifItalic(14))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }

                ForEach(Array(filteredNodes.enumerated()), id: \.element.id) { index, node in
                    AtlasCodeCommitRow(
                        node: node,
                        state: model.state(for: node),
                        ruleId: model.ruleId(for: node),
                        trunk: model.violations?.trunk,
                        isFirst: index == 0,
                        isLast: index == filteredNodes.count - 1,
                        // A resposta da pílula acende o que ela cita: o mapa é
                        // que responde. Sem resposta, ninguém está apagado.
                        isDimmed: !visibleAnchors.isEmpty && !visibleAnchors.contains(node.hash)
                    ) {
                        selectedNode = node
                        Task { await provenanceModel.load(hash: node.hash) }
                    } onLongPress: {
                        guard visibleAnchors.contains(node.hash) else { return }
                        Task { await openWhyBiographyIfAvailable(for: node) }
                    }
                    .accessibilityRotorEntry(id: node.id, in: graphRotor)
                }

                // O grafo mostra os N mais recentes e PARA — o repo tem 8.700.
                // Não é paginação (isso é obra); é a confissão do teto.
                if graph.pagination.hasMore {
                    Text("\(graph.nodes.count) commits mais recentes — há mais história")
                        .font(AtlasFont.serifItalic(12))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                        .accessibilityIdentifier(A11yID.codeGraphTruncated)
                }

                if let mirror = mirrorModel.response {
                    AtlasCodeMirrorCard(response: mirror)
                        .padding(.top, 22)
                }

                if model.week != nil || model.hasHealReceipt {
                    weekSection
                        .padding(.top, 22)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 10)
            .padding(.bottom, 96)  // espaço da pílula
        }
        .refreshable {
            await model.load()
            await mirrorModel.refresh()
        }
        .accessibilityRotor("Violações") {
            ForEach(nodes(in: graph, matching: .violating), id: \.id) { node in
                AccessibilityRotorEntry(Text(rotorLabel(for: node)), id: node.id, in: graphRotor)
            }
        }
        .accessibilityRotor("Curados") {
            ForEach(nodes(in: graph, matching: .healed), id: \.id) { node in
                AccessibilityRotorEntry(Text(rotorLabel(for: node)), id: node.id, in: graphRotor)
            }
        }
    }

    private func worktreesSection(_ worktrees: [AtlasCodeWorktree]) -> some View {
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

    private func graphStateChips(_ graph: AtlasCodeGraphResponse) -> some View {
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

    func nodes(in graph: AtlasCodeGraphResponse, matching state: AtlasCodeNodeState) -> [AtlasCodeGraphNode] {
        graph.nodes.filter { model.state(for: $0) == state }
    }

    func rotorLabel(for node: AtlasCodeGraphNode) -> String {
        node.message ?? String(node.hash.prefix(8))
    }

    func openWhyBiographyIfAvailable(for node: AtlasCodeGraphNode) async {
        await provenanceModel.load(hash: node.hash)
        guard case .loaded(let provenance) = provenanceModel.phase,
              let path = provenance.files.first?.path else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        whyFileTarget = WhyFileTarget(path: path)
    }

    /// Lei 7: a pílula nunca some — nem aqui. E agora ela responde.
    var askPill: some View {
        HStack(spacing: 9) {
            Text("✦")
                .font(AtlasFont.serif(13))
                .foregroundStyle(AtlasTheme.accent)
            Text(anchorLegend ?? "pergunte sobre este repositório")
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(anchorLegend != nil ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityIdentifier(A11yID.codeAskAnchorNote)
            Spacer(minLength: 0)
            if askModel.isAnchoring {
                Button { askModel.clear() } label: {
                    Text("mostrar tudo")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(A11yID.codeAskClear)
            }
            Image(systemName: "chevron.up")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(AtlasTheme.separator, lineWidth: 0.5))
        .contentShape(Capsule())
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            // A pílula abre limpa: a pergunta semeada é de quem semeou.
            askDraft = ""
            showsAskCard = true
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.bottom, 10)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Conversar com o Atlas sobre este repositório")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.codeAskPill)
    }
}

enum AtlasCodeGraphStateFilter: String, CaseIterable, Identifiable {
    case all
    case onMain
    case violating
    case healed
    case history

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "todos"
        case .onMain: return "trunk"
        case .violating: return "desvios"
        case .healed: return "curados"
        case .history: return "história"
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

    private var targetState: AtlasCodeNodeState {
        switch self {
        case .all, .history: return .history
        case .onMain: return .onMain
        case .violating: return .violating
        case .healed: return .healed
        }
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
