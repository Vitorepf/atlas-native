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
}
