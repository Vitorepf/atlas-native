import SwiftUI
import AtlasCore

/// M0 · Grafo Governado. Canvas is an honest E1 fallback until the Metal
/// engine gate (N1) is separately proven; every visible node comes from C22.
struct AtlasCodeView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var model: AtlasCodeModel
    @State private var provenanceModel: AtlasCodeProvenanceModel
    @State private var selectedNode: AtlasCodeGraphNode?
    @State private var showingProvenance = false

    init(client: AtlasClient, repo: String = "atlas-server") {
        _model = State(initialValue: AtlasCodeModel(client: client, repo: repo))
        _provenanceModel = State(initialValue: AtlasCodeProvenanceModel(client: client, repo: repo))
    }

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                header
                content
            }
        }
        .navigationTitle("Código")
        .navigationBarTitleDisplayMode(.inline)
        .task { if model.phase == .idle { await model.load() } }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Grafo Governado", systemImage: "point.3.connected.trianglepath.dotted")
                    .font(AtlasFont.serif(22, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer()
                Text(model.repo)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.accent)
            }
            Text("topologia real · somente leitura")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 18)
        .padding(.bottom, 14)
    }

    @ViewBuilder
    private var content: some View {
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
                    .foregroundStyle(Color(hex: 0xE08C8C))
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
            if let graph = model.graph {
                graphContent(graph)
            } else {
                Text("topologia indisponível")
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func graphContent(_ graph: AtlasCodeGraphResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Circle().fill(graph.defaultBranch == "main" ? AtlasTheme.accent : Color(hex: 0xE08C8C)).frame(width: 7, height: 7)
                    Text(graph.defaultBranch.map { "\($0) · \(graph.nodes.count) nós" } ?? "branch desconhecida")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textSecondary)
                    Spacer()
                    Text("Canvas · Metal pendente")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                .padding(12)
                .background(AtlasTheme.surface, in: RoundedRectangle(cornerRadius: 12))

                if let week = model.week {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("A semana")
                                .font(AtlasFont.serif(18, .semibold))
                                .foregroundStyle(AtlasTheme.textPrimary)
                            Spacer()
                            Text(week.window)
                                .font(AtlasFont.mono(9))
                                .foregroundStyle(AtlasTheme.textTertiary)
                        }
                        HStack(spacing: 16) {
                            weekMetric("commits", value: week.commits)
                            weekMetric("curas", value: week.heals)
                            weekMetric("prevenidas", value: week.prevented)
                            weekMetric("aguardando", value: week.waitingForYou)
                        }
                        Text("notificações desligadas por padrão")
                            .font(AtlasFont.mono(9))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .padding(12)
                    .background(AtlasTheme.surface, in: RoundedRectangle(cornerRadius: 12))
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("A semana: \(week.commits) commits, \(week.heals) curas, \(week.prevented) prevenidas")
                }

                if let violations = model.violations, !violations.violations.isEmpty {
                    VStack(alignment: .leading, spacing: 9) {
                        Text("Sinais de governança")
                            .font(AtlasFont.serif(18, .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        ForEach(violations.violations) { violation in
                            HStack(alignment: .top, spacing: 9) {
                                Text(violation.ruleId)
                                    .font(AtlasFont.mono(10))
                                    .foregroundStyle(Color(hex: 0xE08C8C))
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(violation.target)
                                        .font(AtlasFont.mono(10))
                                        .foregroundStyle(AtlasTheme.textSecondary)
                                    Text("\(violation.plan.count) ações no plano")
                                        .font(AtlasFont.mono(9))
                                        .foregroundStyle(AtlasTheme.textTertiary)
                                }
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(hex: 0xE08C8C).opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("\(violations.violations.count) violações de governança")
                }

                if let heal = model.heal, !heal.stepReceipts.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recibo de cura")
                            .font(AtlasFont.serif(18, .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Text("CURADO SOZINHO · \(heal.mode)")
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.accent)
                        ForEach(heal.stepReceipts) { receipt in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: receipt.status == "completed" ? "checkmark.circle.fill" : "xmark.circle")
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(receipt.action)
                                        .font(AtlasFont.mono(10))
                                    Text(receipt.result)
                                        .font(AtlasFont.mono(9))
                                        .foregroundStyle(AtlasTheme.textTertiary)
                                }
                            }
                        }
                        if heal.healId != nil {
                            Button("Desfazer — com recibo") {
                                Task { await model.undoLastHeal() }
                            }
                            .buttonStyle(.bordered)
                            .tint(AtlasTheme.accent)
                        }
                    }
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .padding(12)
                    .background(AtlasTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Recibo de cura com desfazer")
                }

                GraphCanvas(nodes: graph.nodes, reduceMotion: reduceMotion)
                    .frame(height: min(max(180, CGFloat(graph.nodes.count) * 54), 640))

                ForEach(graph.nodes) { node in
                    Button {
                        selectedNode = node
                        showingProvenance = true
                        Task { await provenanceModel.load(hash: node.hash) }
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(node.hash)
                                .font(AtlasFont.mono(11))
                                .foregroundStyle(AtlasTheme.accent)
                            Text(node.authorName.isEmpty ? node.authorEmail : node.authorName)
                                .font(.system(.subheadline))
                                .foregroundStyle(AtlasTheme.textPrimary)
                            Text(node.refs.joined(separator: " · "))
                                .font(AtlasFont.mono(9))
                                .foregroundStyle(AtlasTheme.textTertiary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 9)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AtlasTheme.surface.opacity(0.65), in: RoundedRectangle(cornerRadius: 10))
                    .buttonStyle(.plain)
                    .accessibilityLabel("Abrir proveniência do commit \(node.hash.prefix(8))")
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showingProvenance) {
            if let node = selectedNode {
                AtlasCodeProvenanceSheet(node: node, phase: provenanceModel.phase)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private func weekMetric(_ label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(String(value))
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(label)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}

private struct AtlasCodeProvenanceSheet: View {
    let node: AtlasCodeGraphNode
    let phase: AtlasCodeProvenanceModel.Phase

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Por que esta linha existe")
                    .font(AtlasFont.serif(25, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(node.hash)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.accent)
                content
                Spacer()
            }
            .padding(24)
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Proveniência")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .idle, .loading:
            HStack(spacing: 10) {
                ProgressView().tint(AtlasTheme.accent)
                Text("lendo o ledger…")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        case .failed(let message):
            Text(message)
                .font(AtlasFont.mono(10))
                .foregroundStyle(Color(hex: 0xE08C8C))
        case .loaded(let provenance):
            VStack(alignment: .leading, spacing: 12) {
                LabeledContent("agente", value: provenance.agent)
                LabeledContent("autor", value: provenance.authorName)
                if let quote = provenance.operatorQuote {
                    Text("\u{201C}\(quote)\u{201D}")
                        .font(AtlasFont.serifItalic(18))
                        .foregroundStyle(AtlasTheme.textPrimary)
                } else {
                    Text("sem proveniência registrada")
                        .font(AtlasFont.serifItalic(17))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                if let traceId = provenance.traceId {
                    Text("trace \(traceId)")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
            }
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textSecondary)
        }
    }
}

private struct GraphCanvas: View {
    let nodes: [AtlasCodeGraphNode]
    let reduceMotion: Bool

    var body: some View {
        Canvas { context, size in
            let x = size.width * 0.15
            let step = nodes.count > 1 ? (size.height - 28) / CGFloat(nodes.count - 1) : size.height / 2
            for index in nodes.indices.dropFirst() {
                let y1 = 14 + CGFloat(index - 1) * step
                let y2 = 14 + CGFloat(index) * step
                var path = Path()
                path.move(to: CGPoint(x: x, y: y1))
                path.addCurve(to: CGPoint(x: x, y: y2), control1: CGPoint(x: x, y: (y1 + y2) / 2), control2: CGPoint(x: x, y: (y1 + y2) / 2))
                context.stroke(path, with: .color(AtlasTheme.accent.opacity(0.45)), lineWidth: 2)
            }
            for index in nodes.indices {
                let y = nodes.count > 1 ? 14 + CGFloat(index) * step : size.height / 2
                let rect = CGRect(x: x - 6, y: y - 6, width: 12, height: 12)
                context.fill(Path(ellipseIn: rect), with: .color(AtlasTheme.accent))
                context.stroke(Path(ellipseIn: rect.insetBy(dx: -2, dy: -2)), with: .color(AtlasTheme.bg), lineWidth: 2)
                let hashLabel = Text(String(nodes[index].hash.prefix(8)))
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(AtlasTheme.textSecondary)
                context.draw(hashLabel, at: CGPoint(x: x + 16, y: y), anchor: .leading)
            }
        }
        .accessibilityLabel("espinha do grafo com \(nodes.count) nós")
        .opacity(reduceMotion ? 1 : 0.98)
    }
}
