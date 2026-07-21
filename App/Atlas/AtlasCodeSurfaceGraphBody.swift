import SwiftUI
import AtlasCore

// density peel B

// MARK: - Host

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

// MARK: - Sections

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

