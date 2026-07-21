import AtlasCore
import Foundation
import SwiftUI

// Cycle 044 fuse → AtlasCodeView.swift

/// M0 · Grafo Governado — o mapa vem primeiro.
///
/// Contrato visual: `docs/proposals/atlas-code-mobile.html` (tela M0).
struct AtlasCodeView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var model: AtlasCodeModel
    @State var provenanceModel: AtlasCodeProvenanceModel
    @State var mirrorModel: AtlasCodeMirrorModel
    @State var askModel: AtlasCodeAskModel
    @State var selectedNode: AtlasCodeGraphNode?
    @State var showsHealReceipt = false
    /// A pílula é porta, não formulário. Tocar abre o card de conversa — o mesmo
    /// gesto do commit, que abre a folha acima do grafo.
    @State var showsAskCard = false
    @State var whyFileTarget: WhyFileTarget?
    @Namespace var graphRotor
    /// A conversa deste repositório continua onde parou. Fechar o card não é
    /// encerrar o assunto; é só tirar a folha da frente do mapa.
    @State var askThreadId: ThreadID?
    /// Pergunta semeada por quem abriu o card (a folha do commit semeia o
    /// commit). Vazia = a pílula abrindo pelo caminho normal.
    @State var askDraft = ""
    /// Commit escolhido por swipe (ou CTA da proveniência) — âncora da pílula.
    /// Nunca abre modal sozinho; o operador toca a pílula para conversar.
    @State var askFocusNode: AtlasCodeGraphNode?
    @State var graphStateFilter: AtlasCodeGraphStateFilter = .all
    @State var showsRepoPicker = false
    var onSwitchRepo: ((String) -> Void)?

    var body: some View {
        codeSheetsBind(
            codeScreenChrome(codeScreenZStack)
        )
    }

    init(
        client: AtlasClient,
        repo: String = "atlas-server",
        onSwitchRepo: ((String) -> Void)? = nil
    ) {
        _model = State(initialValue: AtlasCodeModel(client: client, repo: repo))
        _provenanceModel = State(initialValue: AtlasCodeProvenanceModel(client: client, repo: repo))
        _mirrorModel = State(initialValue: AtlasCodeMirrorModel(client: client, repo: repo))
        _askModel = State(initialValue: AtlasCodeAskModel(client: client, repo: repo))
        self.onSwitchRepo = onSwitchRepo
    }

}

// Pílula de pergunta do grafo + âncora (swipe/proveniência). Lei 7: nunca some.

enum AtlasCodeAskPillA11y {
    static let pillHint = "abre conversa sobre este repositório"
    static let clearLabel = "mostrar tudo no grafo"
    static let clearHint = "remove o recorte dos commits da resposta"

    static func pillPhaseID(isAnchoring: Bool, anchorLegend: String?) -> String {
        isAnchoring ? "anchoring-\(anchorLegend ?? "default")" : "invite"
    }

    static func spokenPill(isAnchoring: Bool, anchorLegend: String?) -> String {
        guard isAnchoring else {
            return "Conversar com o Atlas sobre este repositório"
        }
        let legend = anchorLegend?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !legend.isEmpty {
            return "Conversar com o Atlas, \(legend)"
        }
        return "Conversar com o Atlas, grafo recortado nos commits da resposta"
    }
}

extension AtlasCodeView {
    /// Swipe ou “perguntar” na proveniência: refina a pílula, NÃO abre modal.
    func anchorAskOnCommit(_ node: AtlasCodeGraphNode) {
        selectedNode = nil
        askFocusNode = node
        askDraft = "o que o commit \(citedCommitPrefix(node)) fez, e por quê?"
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
    }

    func openAskFromProvenance(_ node: AtlasCodeGraphNode) {
        anchorAskOnCommit(node)
    }

    func clearAskFocus() {
        askFocusNode = nil
        askDraft = ""
    }

    var pillIsAnchoring: Bool {
        askFocusNode != nil || askModel.isAnchoring
    }

    func citedCommitPrefix(_ node: AtlasCodeGraphNode) -> String {
        var citado = String(node.hash.prefix(10))
        var tamanho = 10
        while !citado.contains(where: \.isNumber), tamanho < node.hash.count {
            tamanho += 4
            citado = String(node.hash.prefix(tamanho))
        }
        return citado
    }

    func swipeFocusLegend(_ node: AtlasCodeGraphNode) -> String {
        let hash = citedCommitPrefix(node)
        guard let message = node.message?.trimmingCharacters(in: .whitespacesAndNewlines),
              !message.isEmpty else {
            return "referência · \(hash)"
        }
        let subject = AtlasConventionalCommit.split(message).subject
        let short = subject.count > 28 ? String(subject.prefix(27)) + "…" : subject
        return "\(hash) · \(short)"
    }

    func openAskPill() {
        // Soft: ask pill is invitation (same class as AgenticPill).
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        if askFocusNode == nil {
            askDraft = ""
        }
        showsAskCard = true
    }

    /// Lei 7: a pílula nunca some — nem aqui. E agora ela responde.
    var askPill: some View {
        HStack(spacing: 9) {
            HStack(spacing: 9) {
                Text("✦")
                    .font(AtlasFont.serif(13))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
                Text(anchorLegend ?? "pergunte sobre este repositório")
                    .font(AtlasFont.serifItalic(13))
                    .foregroundStyle(anchorLegend != nil ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
                    .accessibilityIdentifier(A11yID.codeAskAnchorNote)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                AtlasCodeAskPillA11y.spokenPill(
                    isAnchoring: pillIsAnchoring,
                    anchorLegend: anchorLegend
                )
            )
            .accessibilityHint(AtlasCodeAskPillA11y.pillHint)
            .accessibilityAddTraits(.isButton)
            .accessibilitySortPriority(8) // pílula Code surfaces early in VO
            // VO activate must open ask (tap is on the capsule chrome).
            .accessibilityAction { openAskPill() }
            Spacer(minLength: 0)
            askPillClearButton
            Image(systemName: "chevron.up")
                .atlasSans(10, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .atlasGlassCapsule()
        .overlay(
            Capsule()
                .strokeBorder(AtlasTheme.goldBorder.opacity(0.45), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.22), radius: 10, y: 4)
        .contentShape(Capsule())
        .onTapGesture { openAskPill() }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.bottom, 10)
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.22),
            value: AtlasCodeAskPillA11y.pillPhaseID(
                isAnchoring: pillIsAnchoring,
                anchorLegend: anchorLegend
            )
        )
        // Contain: clear/mostrar tudo buttons stay focusable; invite speaks on the lead.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.codeAskPill)
    }

    @ViewBuilder
    var askPillClearButton: some View {
        if askFocusNode != nil {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                clearAskFocus()
            } label: {
                Text("limpar")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(minHeight: 44, alignment: .center)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Limpar referência do commit")
            .accessibilityHint("Remove o commit da pílula")
            .accessibilityIdentifier(A11yID.codeAskClear)
            .accessibilityAddTraits(.isButton)
        } else if askModel.isAnchoring {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                askModel.clear()
            } label: {
                Text("mostrar tudo")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(minHeight: 44, alignment: .center)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(AtlasCodeAskPillA11y.clearLabel)
            .accessibilityHint(AtlasCodeAskPillA11y.clearHint)
            .accessibilityIdentifier(A11yID.codeAskClear)
            .accessibilityAddTraits(.isButton)
        }
    }
}

extension AtlasCodeView {
    func spokenCodeScreenBusyLabel() -> String? {
        switch model.phase {
        case .idle, .loading:
            return "grafo, \(model.repo), carregando"
        case .failed:
            return "grafo, \(model.repo), falha ao carregar"
        default:
            return nil
        }
    }
}

extension AtlasCodeView {
    func spokenCodeScreenLoadedLabel() -> String {
        let n = model.graph?.nodes.count ?? 0
        if n == 0 { return "grafo, \(model.repo), sem commits neste recorte" }
        return "grafo, \(model.repo), \(n) commit\(n == 1 ? "" : "s")"
    }
}

extension AtlasCodeView {
    func spokenCodeScreenLabel() -> String {
        spokenCodeScreenBusyLabel() ?? spokenCodeScreenLoadedLabel()
    }

    static let codeScreenHint = "mapa governado; pílula e proveniência só com dados publicados"
}

// Legenda da pílula + âncoras visíveis na janela do grafo.

extension AtlasCodeView {
    struct WhyFileTarget: Identifiable {
        let path: String
        var id: String { path }
    }

    /// Interseção âncoras da resposta × nós nesta janela (200). Vazio = não finge.
    var visibleAnchors: Set<String> {
        guard askModel.isAnchoring, let nodes = model.graph?.nodes else { return [] }
        return askModel.anchors.intersection(nodes.map(\.hash))
    }

    /// O que a pílula diz sobre o mapa — contado no que ACENDEU.
    var anchorLegend: String? {
        if let focus = askFocusNode {
            return swipeFocusLegend(focus)
        }
        guard askModel.isAnchoring else { return nil }
        let acesas = visibleAnchors.count
        let citadas = askModel.anchors.count
        if acesas < citadas {
            return anchorLegendPartial(acesas: acesas, citadas: citadas)
        }
        return askModel.anchorNote
    }

    func anchorLegendPartial(acesas: Int, citadas: Int) -> String {
        if acesas == 0 {
            return citadas == 1
                ? "o commit da resposta está fora desta janela"
                : "os \(citadas) commits da resposta estão fora desta janela"
        }
        return "\(acesas) de \(citadas) acesos aqui — o resto está fora desta janela"
    }
}

// Sem back visual (gesto de borda). Grafo + repo glass no inset.

extension AtlasCodeView {
    func codeScreenChrome<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .background(NavigationInteractivePopEnabler())
            .accessibilityIdentifier(A11yID.codeScreen)
            // Contain without fused screen label so graph/radar children stay focusable.
            // Screen spoken summary lives on the toolbar title / repo switcher.
            .accessibilityElement(children: .contain)
            .toolbar { codeToolbar }
            .safeAreaInset(edge: .top, spacing: 0) {
                repoSwitcher
                    .frame(maxWidth: .infinity)
                    .padding(.top, 2)
                    .padding(.bottom, 6)
            }
            .sheet(isPresented: $showsRepoPicker) {
                AtlasCodeRepoPickerSheet(
                    client: session.client,
                    currentRepo: model.repo
                ) { slug in
                    showsRepoPicker = false
                    guard slug != model.repo else { return }
                    Task { await switchToRepo(slug) }
                }
            }
            .task { if model.phase == .idle { await model.load() } }
            .task { await mirrorModel.refresh() }
            // Aquece a frota enquanto o grafo carrega — picker abre instantâneo.
            .task {
                let warmer = AtlasCodeWorkspaceModel(client: session.client)
                await warmer.loadStructure()
            }
    }
}

extension AtlasCodeView {
    /// Swipe-focus ou resposta da pílula: o resto do mapa recua.
    func commitRowIsDimmed(_ node: AtlasCodeGraphNode) -> Bool {
        if let focus = askFocusNode {
            return focus.hash != node.hash
        }
        return !visibleAnchors.isEmpty && !visibleAnchors.contains(node.hash)
    }
}

enum AtlasCodeGraphA11y {
    static func spokenStatus(scanState: AtlasCodeScanState, headline: String) -> String {
        switch scanState {
        case .clean, .unknown:
            return headline
        case .violating:
            return "atenção, \(headline)"
        }
    }
}

extension AtlasCodeGraphA11y {
    static func spokenFilterChip(
        _ option: AtlasCodeGraphStateFilter,
        count: Int,
        active: Bool,
        silent: Bool
    ) -> String {
        var label = "filtrar grafo por \(option.label), \(count) commits"
        if active { label += ", selecionado" }
        if silent { label += ", nenhum commit neste filtro" }
        return label
    }

    static let emptyGraph = "grafo sem commits nesta janela"
}

extension AtlasCodeView {
    @ViewBuilder
    var graphLoadedContent: some View {
        if let graph = model.graph, !graph.nodes.isEmpty {
            graphContent(graph)
        } else {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel(AtlasCodeGraphA11y.emptyGraph)
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

// Graph list: content entry, scroll stack, head chrome, refresh, tail.

extension AtlasCodeView {
    func graphContent(_ graph: AtlasCodeGraphResponse) -> some View {
        let filteredNodes = graphStateFilter.nodes(in: graph.nodes, model: model)
        let filterSilence = graphStateFilter != .all && filteredNodes.isEmpty
        let scroll = graphListScroll(
            graph: graph,
            filteredNodes: filteredNodes,
            filterSilence: filterSilence
        )
        return graphAccessibilityRotors(graph: graph, content: scroll)
    }

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

    func graphListScrollRefresh() async {
        await model.load()
        await mirrorModel.refresh()
    }

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

    @ViewBuilder
    func graphListTail(graph: AtlasCodeGraphResponse) -> some View {
        graphListTruncationCaption(graph)
        graphListMirrorCard
        graphListWeekTail
    }

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

    @ViewBuilder
    var graphListMirrorCard: some View {
        if let mirror = mirrorModel.response {
            AtlasCodeMirrorCard(response: mirror)
                .padding(.top, 22)
        }
    }

    @ViewBuilder
    var graphListWeekTail: some View {
        if model.week != nil || model.hasHealReceipt {
            weekSection
                .padding(.top, 22)
        }
    }
}

// Graph commit rows: ForEach, rotor, row build, init, tap handlers.

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

    func graphCommitRowRotor<Row: View>(_ row: Row, node: AtlasCodeGraphNode) -> some View {
        row.accessibilityRotorEntry(id: node.id, in: graphRotor)
    }

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

    /// Vizinhos do filtro alimentam a continuidade da lane (fork/merge).
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

    func graphCommitRowSelect(_ node: AtlasCodeGraphNode) {
        selectedNode = node
        Task { await provenanceModel.load(hash: node.hash) }
    }

    func graphCommitRowLongPress(_ node: AtlasCodeGraphNode) {
        guard visibleAnchors.contains(node.hash) else { return }
        // softImpact only when why opens (openWhyBiographyIfAvailable) — no double tap.
        Task { await openWhyBiographyIfAvailable(for: node) }
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

// O init voltou para AtlasCodeView.swift: o backing `_state` de @State só é
// acessível no mesmo arquivo (limitação Swift), não em extension separada.

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

// Sem remount da NavigationStack: a lentidão era destruir @State + 4 GETs.

extension AtlasCodeView {
    func switchToRepo(_ slug: String) async {
        guard slug != model.repo else { return }
        selectedNode = nil
        showsHealReceipt = false
        showsAskCard = false
        whyFileTarget = nil
        askThreadId = nil
        askDraft = ""
        askFocusNode = nil
        graphStateFilter = .all

        model.adoptRepo(slug)
        provenanceModel.adoptRepo(slug)
        mirrorModel.adoptRepo(slug)
        askModel.adoptRepo(slug)

        async let graphLoad: Void = model.load()
        async let mirrorLoad: Void = mirrorModel.refresh()
        await graphLoad
        await mirrorLoad
    }
}

// Masthead do grafo: título Fraunces no principal.
// Repo glass vive no safeAreaInset (tap confiável — toolbar .principal
// clipava a pílula fora da hit-area da nav bar).

extension AtlasCodeView {
    var codeToolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Grafo")
                .font(AtlasFont.serif(20))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(spokenCodeScreenLabel())
                .accessibilityHint(Self.codeScreenHint)
        }
    }

    /// Troca de repositório — Liquid Glass, sempre abaixo do título.
    var repoSwitcher: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            showsRepoPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(model.repo)
                    .font(AtlasFont.mono(10.5))
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .atlasSans(8, .semibold)
                    .opacity(0.55)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .frame(minHeight: 48) // HIG 44+; match chrome pill breath
            .contentShape(Capsule())
            .atlasGlassCapsule()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("repositório \(model.repo)")
        .accessibilityHint("troca de repositório")
        .accessibilityIdentifier(A11yID.codeRepoSwitcher)
        .accessibilityAddTraits(.isButton)
    }
}

// Folhas ask/why do grafo.
// Experiência de página editorial: fundo Atlas, detent large, sem grabber
// de sheet nem botão voltar — fecha no gesto.

struct AtlasCodeAskWhySheetsModifier: ViewModifier {
    let session: AtlasSession
    let model: AtlasCodeModel
    let askModel: AtlasCodeAskModel
    @Binding var showsAskCard: Bool
    @Binding var whyFileTarget: AtlasCodeView.WhyFileTarget?
    @Binding var askThreadId: ThreadID?
    @Binding var askDraft: String

    func body(content: Content) -> some View {
        askWhyWhySheet(on: askWhyAskSheet(on: content))
    }

    func askWhyAskSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showsAskCard) {
                askConversationSheet
            }
    }

    func askWhyWhySheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $whyFileTarget) { target in
                AtlasCodeWhySheet(client: session.client, repo: model.repo, file: target.path)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
    }

    var askConversationSheet: some View {
        ConversationView(
            client: session.client,
            threadId: askThreadId,
            title: "Código · \(model.repo)",
            emptyPrompt: "O que você quer saber deste repositório?",
            emptySuggestions: AtlasCodeAskSuggestions.all,
            taskKind: "code",
            workspace: model.repo,
            draft: askDraft,
            turnFacts: { [askModel] question in await askModel.facts(for: question) },
            onThread: { askThreadId = $0 },
            hidesNavigationBack: true
        )
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(AtlasTheme.bg)
        .presentationCornerRadius(28)
        .interactiveDismissDisabled(false)
    }
}

// Folhas do grafo: entry, bind, modifier, proveniência, heal.
// Zero mudança de rota.

extension View {
    func atlasCodeSheets(
        session: AtlasSession,
        model: AtlasCodeModel,
        provenanceModel: AtlasCodeProvenanceModel,
        askModel: AtlasCodeAskModel,
        selectedNode: Binding<AtlasCodeGraphNode?>,
        showsHealReceipt: Binding<Bool>,
        showsAskCard: Binding<Bool>,
        whyFileTarget: Binding<AtlasCodeView.WhyFileTarget?>,
        askThreadId: Binding<ThreadID?>,
        askDraft: Binding<String>,
        onProvenanceAsk: @escaping (AtlasCodeGraphNode) -> Void
    ) -> some View {
        modifier(AtlasCodeSheetsModifier(
            session: session,
            model: model,
            provenanceModel: provenanceModel,
            askModel: askModel,
            selectedNode: selectedNode,
            showsHealReceipt: showsHealReceipt,
            showsAskCard: showsAskCard,
            whyFileTarget: whyFileTarget,
            askThreadId: askThreadId,
            askDraft: askDraft,
            onProvenanceAsk: onProvenanceAsk
        ))
    }
}

extension AtlasCodeView {
    func codeSheetsBind<Content: View>(_ content: Content) -> some View {
        content.atlasCodeSheets(
            session: session,
            model: model,
            provenanceModel: provenanceModel,
            askModel: askModel,
            selectedNode: $selectedNode,
            showsHealReceipt: $showsHealReceipt,
            showsAskCard: $showsAskCard,
            whyFileTarget: $whyFileTarget,
            askThreadId: $askThreadId,
            askDraft: $askDraft,
            onProvenanceAsk: openAskFromProvenance
        )
    }
}

struct AtlasCodeSheetsModifier: ViewModifier {
    let session: AtlasSession
    let model: AtlasCodeModel
    let provenanceModel: AtlasCodeProvenanceModel
    let askModel: AtlasCodeAskModel
    @Binding var selectedNode: AtlasCodeGraphNode?
    @Binding var showsHealReceipt: Bool
    @Binding var showsAskCard: Bool
    @Binding var whyFileTarget: AtlasCodeView.WhyFileTarget?
    @Binding var askThreadId: ThreadID?
    @Binding var askDraft: String
    let onProvenanceAsk: (AtlasCodeGraphNode) -> Void

    func body(content: Content) -> some View {
        askWhySheetsBind(provenanceAndHealSheets(on: content))
    }

    func askWhySheetsBind<Content: View>(_ content: Content) -> some View {
        content.modifier(AtlasCodeAskWhySheetsModifier(
            session: session,
            model: model,
            askModel: askModel,
            showsAskCard: $showsAskCard,
            whyFileTarget: $whyFileTarget,
            askThreadId: $askThreadId,
            askDraft: $askDraft
        ))
    }

    @ViewBuilder
    func provenanceAndHealSheets<Content: View>(on content: Content) -> some View {
        healReceiptSheet(on: provenanceSheetBind(on: content))
    }

    @ViewBuilder
    func provenanceSheetBind<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $selectedNode) { node in
                provenanceSheetPresent(provenanceSheetContent(for: node))
            }
    }

    func provenanceSheetContent(for node: AtlasCodeGraphNode) -> AtlasCodeProvenanceSheet {
        AtlasCodeProvenanceSheet(
            client: session.client,
            repo: model.repo,
            node: node,
            state: model.state(for: node),
            ruleId: model.ruleId(for: node),
            ruleCanon: model.ruleCanon(for: node),
            trunk: model.violations?.trunk,
            phase: provenanceModel.phase,
            onAsk: { onProvenanceAsk(node) }
        )
    }

    func provenanceSheetPresent<Content: View>(_ sheet: Content) -> some View {
        sheet
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    func healReceiptSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showsHealReceipt) {
                if let heal = model.heal {
                    AtlasCodeHealReceiptSheet(heal: heal) { Task { await model.undoLastHeal() } }
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            }
    }
}
