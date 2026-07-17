import SwiftUI
import AtlasCore

extension AtlasCodeView {
    @ViewBuilder
    var content: some View {
        switch model.phase {
        case .idle, .loading:
            TraceEvidenceLoading(text: "lendo a topologia do repositório…", reduceMotion: reduceMotion)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            graphFailure(message)
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
        let scroll = ScrollView {
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
            .padding(.bottom, 96)
        }
        .refreshable {
            await model.load()
            await mirrorModel.refresh()
        }
        return graphAccessibilityRotors(graph: graph, content: scroll)
    }
}
