import SwiftUI
import AtlasCore

// IDLE-COMPRESS peel AtlasCode graph content/list from Surface (canon §7 · same domain)

extension AtlasCodeView {
    @ViewBuilder
    var graphLoadedContent: some View {
        if let graph = model.graph, !graph.nodes.isEmpty {
            graphContent(graph)
        } else {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel(AtlasCodeGraphJudgment.emptyGraph)
        }
    }
}

extension AtlasCodeView {
    var graphLoadingContent: some View {
        TraceEvidenceLoading(text: "lendo a topologia do repositório…", reduceMotion: reduceMotion)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension AtlasCodeView {
    @ViewBuilder
    var content: some View {
        switch model.phase {
        case .idle, .loading:
            graphLoadingContent
        case .failed(let message):
            graphFailure(message)
        case .loaded:
            graphLoadedContent
        }
    }
}

extension AtlasCodeView {
    func graphContent(_ graph: AtlasCodeGraphResponse) -> some View {
        let filteredNodes = graphStateFilter.nodes(in: graph.nodes, model: model)
        let ranked = AtlasCodeGraphJudgment.rankNodes(
            filteredNodes,
            model: model,
            scan: model.scanState
        )
        let filterSilence = graphStateFilter != .all && ranked.isEmpty
        let scroll = graphListScroll(
            graph: graph,
            filteredNodes: ranked,
            filterSilence: filterSilence
        )
        return graphAccessibilityRotors(graph: graph, content: scroll)
    }
}

extension AtlasCodeView {
    func graphCommitRowRotor<Row: View>(_ row: Row, node: AtlasCodeGraphNode) -> some View {
        row.accessibilityRotorEntry(id: node.id, in: graphRotor)
    }
}

extension AtlasCodeView {
    func graphCommitRowHandlers(for node: AtlasCodeGraphNode) -> (
        onSelect: () -> Void,
        onLongPress: () -> Void,
        onAsk: () -> Void
    ) {
        (
            onSelect: { graphCommitRowSelect(node) },
            onLongPress: { graphCommitRowLongPress(node) },
            onAsk: { anchorAskOnCommit(node) }
        )
    }
}

extension AtlasCodeView {
    func graphCommitRowInit(
        node: AtlasCodeGraphNode,
        index: Int,
        total: Int,
        filteredNodes: [AtlasCodeGraphNode]
    ) -> (
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        ruleId: String?,
        trunk: String?,
        isFirst: Bool,
        isLast: Bool,
        aboveState: AtlasCodeNodeState?,
        belowState: AtlasCodeNodeState?,
        isDimmed: Bool
    ) {
        let above: AtlasCodeNodeState? = index > 0
            ? model.state(for: filteredNodes[index - 1])
            : nil
        let below: AtlasCodeNodeState? = index + 1 < filteredNodes.count
            ? model.state(for: filteredNodes[index + 1])
            : nil
        return (
            node: node,
            state: model.state(for: node),
            ruleId: model.ruleId(for: node),
            trunk: model.violations?.trunk,
            isFirst: index == 0,
            isLast: index == total - 1,
            aboveState: above,
            belowState: below,
            isDimmed: commitRowIsDimmed(node)
        )
    }
}

extension AtlasCodeView {
    func graphCommitRowView(
        node: AtlasCodeGraphNode,
        index: Int,
        total: Int,
        filteredNodes: [AtlasCodeGraphNode]
    ) -> AtlasCodeCommitRow {
        let initArgs = graphCommitRowInit(
            node: node,
            index: index,
            total: total,
            filteredNodes: filteredNodes
        )
        let handlers = graphCommitRowHandlers(for: node)
        return AtlasCodeCommitRow(
            node: initArgs.node,
            state: initArgs.state,
            ruleId: initArgs.ruleId,
            trunk: initArgs.trunk,
            isFirst: initArgs.isFirst,
            isLast: initArgs.isLast,
            aboveState: initArgs.aboveState,
            belowState: initArgs.belowState,
            isDimmed: initArgs.isDimmed,
            onTap: handlers.onSelect,
            onLongPress: handlers.onLongPress,
            onAsk: handlers.onAsk
        )
    }
}

extension AtlasCodeView {
    @ViewBuilder
    func graphCommitRow(
        node: AtlasCodeGraphNode,
        index: Int,
        total: Int,
        filteredNodes: [AtlasCodeGraphNode]
    ) -> some View {
        graphCommitRowRotor(
            graphCommitRowView(
                node: node,
                index: index,
                total: total,
                filteredNodes: filteredNodes
            ),
            node: node
        )
    }
}

extension AtlasCodeView {
    func graphCommitRowSelect(_ node: AtlasCodeGraphNode) {
        selectedNode = node
        Task { await provenanceModel.load(hash: node.hash) }
    }

    func graphCommitRowLongPress(_ node: AtlasCodeGraphNode) {
        guard visibleAnchors.contains(node.hash) else { return }
        Task { await openWhyBiographyIfAvailable(for: node) }
    }
}

extension AtlasCodeView {
    @ViewBuilder
    func graphCommitRows(_ filteredNodes: [AtlasCodeGraphNode]) -> some View {
        ForEach(Array(filteredNodes.enumerated()), id: \.element.id) { index, node in
            graphCommitRow(
                node: node,
                index: index,
                total: filteredNodes.count,
                filteredNodes: filteredNodes
            )
        }
    }
}

extension AtlasCodeView {
    func graphListScrollRefresh() async {
        await model.load()
        await mirrorModel.refresh()
    }
}

extension AtlasCodeView {
    func graphListScroll(
        graph: AtlasCodeGraphResponse,
        filteredNodes: [AtlasCodeGraphNode],
        filterSilence: Bool
    ) -> some View {
        ScrollView {
            graphListScrollBody(
                graph: graph,
                filteredNodes: filteredNodes,
                filterSilence: filterSilence
            )
        }
        .refreshable { await graphListScrollRefresh() }
    }
}

extension AtlasCodeView {
    @ViewBuilder
    func graphListScrollBody(
        graph: AtlasCodeGraphResponse,
        filteredNodes: [AtlasCodeGraphNode],
        filterSilence: Bool
    ) -> some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            graphListScrollHead(graph: graph, filterSilence: filterSilence)
            graphCommitRows(filteredNodes)
            graphListTail(graph: graph)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 10)
        .padding(.bottom, 96)
    }
}

extension AtlasCodeView {
    @ViewBuilder
    func graphListScrollHead(
        graph: AtlasCodeGraphResponse,
        filterSilence: Bool
    ) -> some View {
        statusCapsule

        if !graph.worktrees.isEmpty {
            worktreesSection(graph.worktrees)
                .padding(.bottom, 14)
        }

        graphStateChips(graph, filterSilence: filterSilence)
            .padding(.bottom, 10)
    }
}

extension AtlasCodeView {
    @ViewBuilder
    var graphListMirrorCard: some View {
        if let mirror = mirrorModel.response {
            AtlasCodeMirrorCard(response: mirror)
                .padding(.top, 22)
        }
    }
}

extension AtlasCodeView {
    @ViewBuilder
    func graphListTruncationCaption(_ graph: AtlasCodeGraphResponse) -> some View {
        if graph.pagination.hasMore {
            Text("\(graph.nodes.count) commits mais recentes — há mais história")
                .font(AtlasFont.serifItalic(12))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 16)
                .accessibilityIdentifier(A11yID.codeGraphTruncated)
        }
    }
}

extension AtlasCodeView {
    @ViewBuilder
    var graphListWeekTail: some View {
        if model.week != nil || model.hasHealReceipt {
            weekSection
                .padding(.top, 22)
        }
    }
}

extension AtlasCodeView {
    @ViewBuilder
    func graphListTail(graph: AtlasCodeGraphResponse) -> some View {
        graphListTruncationCaption(graph)
        // WAVE-043: exclusive repo health face before mirror/week peels.
        AtlasCodeRepoHealthStrip(model: model, mirror: mirrorModel.response)
            .padding(.top, 18)
        graphListMirrorCard
        graphListWeekTail
    }
}

extension AtlasCodeView {
    func nodes(in graph: AtlasCodeGraphResponse, matching state: AtlasCodeNodeState) -> [AtlasCodeGraphNode] {
        graph.nodes.filter { model.state(for: $0) == state }
    }

    func rotorLabel(for node: AtlasCodeGraphNode) -> String {
        node.message ?? String(node.hash.prefix(8))
    }
}

extension AtlasCodeView {
    func openWhyBiographyIfAvailable(for node: AtlasCodeGraphNode) async {
        await provenanceModel.load(hash: node.hash)
        guard case .loaded(let provenance) = provenanceModel.phase,
              let path = provenance.files.first?.path else { return }
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        whyFileTarget = WhyFileTarget(path: path)
    }
}

extension AtlasCodeView {
    @ViewBuilder
    func graphAccessibilityRotors(graph: AtlasCodeGraphResponse, content: some View) -> some View {
        content
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
}

extension AtlasCodeView {
    @ViewBuilder
    func graphFailure(_ message: String) -> some View {
        AtlasCodeLoadFailureEmpty(
            headline: "não consegui ler este repositório",
            message: message,
            onRetry: { Task { await model.load() } }
        )
    }
}

extension AtlasCodeView {
    var codeScreenZStack: some View {
        // Fundo como .background: destrava o scroll-edge material da barra.
        ZStack(alignment: .bottom) {
            content
            askPill
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
    }
}

