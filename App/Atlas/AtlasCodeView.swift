import SwiftUI
import AtlasCore

/// M0 · Grafo Governado — o mapa vem primeiro.
///
/// Contrato visual: `docs/proposals/atlas-code-mobile.html` (tela M0).
/// Leis aplicadas aqui: mapa primeiro (3), estado por exceção (4), um sinal
/// primário por violação (5), linguagem humana em cima e máquina embaixo do
/// vidro (6), a pílula nunca some (7), autonomia > aprovação (1: só veto).
/// Gramática de cor (AtlasCore): dourado = na main · vermelho = fora ·
/// verde = curado. Cor é estado; autor e tipo já são texto.
struct AtlasCodeView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var model: AtlasCodeModel
    @State private var provenanceModel: AtlasCodeProvenanceModel
    @State private var mirrorModel: AtlasCodeMirrorModel
    @State private var selectedNode: AtlasCodeGraphNode?
    @State private var showsHealReceipt = false

    init(client: AtlasClient, repo: String = "atlas-server") {
        _model = State(initialValue: AtlasCodeModel(client: client, repo: repo))
        _provenanceModel = State(initialValue: AtlasCodeProvenanceModel(client: client, repo: repo))
        _mirrorModel = State(initialValue: AtlasCodeMirrorModel(client: client, repo: repo))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AtlasTheme.bg.ignoresSafeArea()
            content
            askPill
        }
        .navigationTitle("Grafo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text(model.repo)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityLabel("repositório \(model.repo)")
            }
        }
        .task { if model.phase == .idle { await model.load() } }
        .task { await mirrorModel.refresh() }
        .sheet(item: $selectedNode) { node in
            AtlasCodeProvenanceSheet(node: node, phase: provenanceModel.phase)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showsHealReceipt) {
            if let heal = model.heal {
                AtlasCodeHealReceiptSheet(heal: heal) { Task { await model.undoLastHeal() } }
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Estados

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

    // MARK: - O mapa

    private func graphContent(_ graph: AtlasCodeGraphResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                statusCapsule
                    .padding(.bottom, 14)

                ForEach(Array(graph.nodes.enumerated()), id: \.element.id) { index, node in
                    AtlasCodeCommitRow(
                        node: node,
                        state: model.state(for: node),
                        ruleId: model.ruleId(for: node),
                        isFirst: index == 0,
                        isLast: index == graph.nodes.count - 1
                    ) {
                        selectedNode = node
                        Task { await provenanceModel.load(hash: node.hash) }
                    }
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
    }

    /// Cápsula central e simétrica: a única voz do estado geral.
    private var statusCapsule: some View {
        HStack(spacing: 7) {
            Image(systemName: model.hasViolations ? "exclamationmark.triangle" : "checkmark")
                .font(.system(size: 10, weight: .semibold))
            Text(model.statusHeadline)
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
        }
        .foregroundStyle(model.hasViolations ? AtlasCodePalette.alert : AtlasCodePalette.healed)
        .padding(.horizontal, 15)
        .padding(.vertical, 7)
        .background(
            Capsule().fill((model.hasViolations ? AtlasCodePalette.alert : AtlasCodePalette.healed).opacity(0.09))
        )
        .overlay(
            Capsule().strokeBorder((model.hasViolations ? AtlasCodePalette.alert : AtlasCodePalette.healed).opacity(0.35), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: model.hasViolations)
        .accessibilityLabel(model.statusHeadline)
        .accessibilityIdentifier("code-status")
    }

    /// A semana + o recibo da noite: fatos consumados, nunca pedidos.
    private var weekSection: some View {
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
                    weekMetric("esperando você", value: week.waitingForYou)
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("A semana: \(week.commits) commits, \(week.heals) curas, \(week.prevented) prevenidas, \(week.waitingForYou) esperando você")
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
                .accessibilityIdentifier("code-heal-receipt")
            }
        }
    }

    private func weekMetric(_ label: String, value: Int) -> some View {
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

    /// Lei 7: a pílula nunca some — nem aqui.
    private var askPill: some View {
        HStack(spacing: 9) {
            Image(systemName: "plus")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 22, height: 22)
                .background(Circle().fill(AtlasTheme.surfaceHi))
            Text("por que essa branch existe?")
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
            Spacer()
            Image(systemName: "mic")
                .font(.system(size: 11))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(AtlasTheme.separator, lineWidth: 0.5))
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.bottom, 10)
        .accessibilityLabel("Perguntar ao Atlas sobre o código")
        .accessibilityIdentifier("code-ask-pill")
    }
}

// MARK: - Paleta do domínio (gramática de estado)

enum AtlasCodePalette {
    static let onMain = AtlasTheme.accent          // dourado: a cor da espinha
    static let alert = Color(hex: 0xE08C8C)        // vermelho: fora da main
    static let healed = Color(hex: 0x83B46D)       // verde: curado
    static let history = Color(hex: 0x647682)      // cinza: história alcançável

    static func color(for state: AtlasCodeNodeState) -> Color {
        switch state {
        case .onMain: return onMain
        case .violating: return alert
        case .healed: return healed
        case .history: return history
        }
    }
}

// MARK: - Linha do commit (mensagem é a manchete)

private struct AtlasCodeCommitRow: View {
    let node: AtlasCodeGraphNode
    let state: AtlasCodeNodeState
    let ruleId: String?
    let isFirst: Bool
    let isLast: Bool
    let onTap: () -> Void

    private var color: Color { AtlasCodePalette.color(for: state) }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                spine
                VStack(alignment: .leading, spacing: 4) {
                    // Manchete: a mensagem do commit. Sem mensagem, o hash é o
                    // último recurso honesto — nunca inventamos um título.
                    Text(node.message ?? String(node.hash.prefix(8)))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(state == .violating ? AtlasCodePalette.alert : AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    HStack(spacing: 6) {
                        Text(node.authorName.isEmpty ? node.authorEmail : node.authorName)
                        Text("·")
                        Text(AtlasCodeRelativeTime.short(from: node.authoredAt))
                        if let ruleId {
                            Text("·")
                            Text(ruleId)
                                .foregroundStyle(AtlasCodePalette.alert)
                        }
                    }
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 7)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        .accessibilityIdentifier("code-commit-\(node.hash.prefix(8))")
    }

    /// A espinha: linha contínua + o nó. O desvio salta ao olho pela cor.
    private var spine: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(isFirst ? Color.clear : AtlasTheme.accent.opacity(0.55))
                .frame(width: 2, height: 8)
            ZStack {
                if state == .violating {
                    Circle()
                        .strokeBorder(AtlasCodePalette.alert.opacity(0.5), lineWidth: 1.4)
                        .frame(width: 22, height: 22)
                }
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().strokeBorder(AtlasTheme.bg, lineWidth: 2))
            }
            .frame(width: 22, height: 22)
            Rectangle()
                .fill(isLast ? Color.clear : AtlasTheme.accent.opacity(0.55))
                .frame(width: 2)
                .frame(maxHeight: .infinity)
        }
        .frame(width: 22)
        .accessibilityHidden(true)
    }

    private var accessibilityText: String {
        let title = node.message ?? String(node.hash.prefix(8))
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        switch state {
        case .violating: return "\(title), por \(author), fora da main\(ruleId.map { ", regra \($0)" } ?? "")"
        case .healed: return "\(title), por \(author), curado"
        case .onMain: return "\(title), por \(author), na main"
        case .history: return "\(title), por \(author)"
        }
    }
}

enum AtlasCodeRelativeTime {
    /// Tempo relativo curto e humano, a partir do epoch do git.
    static func short(from epoch: Int, now: Date = Date()) -> String {
        let seconds = max(0, Int(now.timeIntervalSince1970) - epoch)
        switch seconds {
        case ..<3600: return "\(max(1, seconds / 60))min"
        case ..<86_400: return "\(seconds / 3600)h"
        case ..<2_592_000: return "\(seconds / 86_400)d"
        default: return "\(seconds / 2_592_000)mês"
        }
    }
}

// MARK: - Folha: por que esta linha existe (C23)

private struct AtlasCodeProvenanceSheet: View {
    let node: AtlasCodeGraphNode
    let phase: AtlasCodeProvenanceModel.Phase

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("PROVENIÊNCIA")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.4)
                        .foregroundStyle(AtlasTheme.accent)
                    Text(node.message ?? "Por que esta linha existe")
                        .font(AtlasFont.serif(21, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    // Máquina embaixo do vidro: o hash mora aqui, não na lista.
                    Text(node.hash)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .textSelection(.enabled)
                    content
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(22)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .idle, .loading:
            HStack(spacing: 10) {
                ProgressView().tint(AtlasTheme.accent)
                Text("lendo o ledger…")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.top, 6)
        case .failed(let message):
            Text(message)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasCodePalette.alert)
        case .loaded(let provenance):
            VStack(alignment: .leading, spacing: 14) {
                block("Sua frase") {
                    if let quote = provenance.operatorQuote {
                        Text("\u{201C}\(quote)\u{201D}")
                            .font(AtlasFont.serifItalic(16))
                            .foregroundStyle(AtlasTheme.textPrimary)
                    } else {
                        // Ausência é dita, nunca preenchida.
                        Text("sem proveniência registrada")
                            .font(AtlasFont.serifItalic(15))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                }
                if let gates = provenance.gates, !gates.isEmpty {
                    block("Prova no ledger") {
                        AtlasCodeChipRow(items: gates)
                    }
                }
                if let obra = provenance.obra, !obra.isEmpty {
                    block("Obra") {
                        AtlasCodeChipRow(items: obra)
                    }
                }
                block("Autor") {
                    Text("\(provenance.authorName) · \(provenance.agent)")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
            }
        }
    }

    private func block(_ title: String, @ViewBuilder body: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title.uppercased())
                .font(.system(size: 8.5, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(AtlasTheme.textTertiary)
            body()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct AtlasCodeChipRow: View {
    let items: [String]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasCodePalette.healed)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay(
                        Capsule().strokeBorder(AtlasCodePalette.healed.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Folha: Recibo de Cura (C25 — fato consumado, só veto)

private struct AtlasCodeHealReceiptSheet: View {
    let heal: AtlasCodeHealResponse
    let onUndo: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 7) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                    Text("CURADO SOZINHO · \(heal.mode.uppercased())")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.2)
                }
                .foregroundStyle(AtlasCodePalette.healed)

                Text("você não foi necessário")
                    .font(AtlasFont.serif(20, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(heal.stepReceipts) { receipt in
                        HStack(alignment: .top, spacing: 9) {
                            Image(systemName: receipt.status == "completed" ? "checkmark" : "xmark")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(receipt.status == "completed" ? AtlasCodePalette.healed : AtlasCodePalette.alert)
                                .padding(.top, 2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(receipt.action)
                                    .font(.system(size: 13))
                                    .foregroundStyle(AtlasTheme.textPrimary)
                                Text(receipt.result)
                                    .font(AtlasFont.mono(9))
                                    .foregroundStyle(AtlasTheme.textTertiary)
                            }
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))

                // Único verbo humano: o veto retroativo. Nunca "Aprovar".
                if heal.healId != nil {
                    Button {
                        onUndo()
                        dismiss()
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "arrow.uturn.backward")
                            Text("Desfazer — com recibo")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .background(AtlasTheme.surface, in: RoundedRectangle(cornerRadius: 13))
                        .overlay(
                            RoundedRectangle(cornerRadius: 13)
                                .strokeBorder(AtlasTheme.separator, lineWidth: 0.5)
                        )
                    }
                    .accessibilityIdentifier("code-heal-undo")
                }
                Spacer(minLength: 0)
            }
            .padding(22)
        }
    }
}
