import AtlasCore
import Foundation
import SwiftUI
import Observation

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


/// A exceção do domínio Código, resolvida de dado real.
///
/// O hub NÃO repete a área (decisão do operador, 15/07): a única porta do
/// Atlas Código é o ícone da barra, à esquerda do masthead. Este model
/// alimenta o ponto vermelho desse ícone — estado por exceção: sem violação
/// real, nenhum sinal; e ele some sozinho quando o Atlas cura.
@MainActor
@Observable
final class AtlasCodeHubModel {
    private let client: AtlasClient
    /// Exceção resolvida a partir de dado real. `nil` = silêncio (nunca "0".)
    private(set) var exception: Exception?

    struct Exception: Equatable {
        let repo: String
        let ruleId: String
        let count: Int
    }

    init(client: AtlasClient) {
        self.client = client
    }

    /// Varre as áreas e mantém apenas a primeira exceção real. Falha de rede
    /// não inventa exceção nem apaga a anterior de forma silenciosa: sem
    /// resposta, a linha simplesmente não fala.
    /// Varre os repositórios recentes — o trabalho vivo. Sem resposta, o
    /// ponto não acende: ausência nunca vira exceção.
    func refresh() async {
        guard let workspace = try? await client.getCodeWorkspace() else { return }

        // Apagar o ponto é uma AFIRMAÇÃO ("varri e está são") e só pode sair
        // de uma varredura que respondeu. Antes, se TODAS as leituras
        // falhassem, o laço terminava e `exception = nil` apagava o ponto
        // sobre uma frota que ninguém varreu — a mesma alta em verde da
        // cápsula, em miniatura. Falha mantém o estado anterior: o ponto que
        // estava aceso continua aceso até uma leitura real dizer o contrário.
        var scanned = false
        for repo in workspace.recents {
            guard let response = try? await client.getCodeViolations(repo: repo.slug) else { continue }
            scanned = true
            if let first = response.violations.first {
                exception = Exception(repo: repo.name, ruleId: first.ruleId, count: response.violations.count)
                return
            }
        }
        if scanned { exception = nil }
    }
}


// Cycle 045 fuse → AtlasCodeWeek.swift

extension AtlasCodeWeekUI {
    static func isQuiet(commits: Int, heals: Int, prevented: Int) -> Bool {
        commits == 0 && heals == 0 && prevented == 0
    }

    static func isQuiet(_ week: AtlasCodeWeek) -> Bool {
        isQuiet(commits: week.commits, heals: week.heals, prevented: week.prevented)
    }
}

enum AtlasCodeWeekUI {
    static func spokenLabel(window: String, commits: Int, heals: Int, prevented: Int) -> String {
        AtlasCodeWeekUISpoken.spokenLabel(window: window, commits: commits, heals: heals, prevented: prevented)
    }

    static func spokenLabel(_ week: AtlasCodeWeek) -> String {
        AtlasCodeWeekUISpoken.spokenLabel(week)
    }
}

extension AtlasCodeWeekUI {
    static func weekPhaseID(_ week: AtlasCodeWeek) -> String {
        if isQuiet(week) { return "quiet-\(week.window)" }
        return "active-\(week.window)-\(week.commits)-\(week.heals)-\(week.prevented)"
    }
}

enum AtlasCodeWeekUISpoken {
    static func spokenLabel(window: String, commits: Int, heals: Int, prevented: Int) -> String {
        AtlasCodeWeekUISpokenQuiet.spokenLabel(
            window: window, commits: commits, heals: heals, prevented: prevented
        )
    }

    static func spokenLabel(_ week: AtlasCodeWeek) -> String {
        spokenLabel(
            window: week.window,
            commits: week.commits,
            heals: week.heals,
            prevented: week.prevented
        )
    }
}

enum AtlasCodeWeekUISpokenQuiet {
    static func spokenLabel(window: String, commits: Int, heals: Int, prevented: Int) -> String {
        if AtlasCodeWeekUI.isQuiet(commits: commits, heals: heals, prevented: prevented) {
            return "A semana \(window), semana quieta, sem commits nem curas"
        }
        var parts = ["A semana \(window)"]
        if commits > 0 { parts.append("\(commits) commit\(commits == 1 ? "" : "s")") }
        if heals > 0 { parts.append("\(heals) cura\(heals == 1 ? "" : "s")") }
        if prevented > 0 { parts.append("\(prevented) prevenida\(prevented == 1 ? "" : "s")") }
        return parts.joined(separator: ", ")
    }
}


// Cycle 044 fuse → AtlasCodeFileRow.swift

/// Uma linha por arquivo. O VERBO é a forma do símbolo, não a cor: cor aqui
/// é reservada ao estado do commit (main/fora/curado) e mentiria se pintasse
/// tipo de mudança de vermelho dentro de um commit saudável.
struct AtlasCodeFileRow: View {
    let file: AtlasCodeFileChange
    var accessibilityIdentifier: String?

    var body: some View {
        lead
            .padding(.vertical, 9)
            .frame(minHeight: 48, alignment: .center)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AtlasCodeFileRowA11y.spokenFile(file))
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

/// Contagens só quando o payload publica; binário sem inventar linhas.

enum AtlasCodeFileRowA11y {
    static func spokenFile(_ file: AtlasCodeFileChange) -> String {
        var parts = [file.path, verb(for: file.status)]
        if let from = file.renamedFrom { parts.append("de \(from)") }
        if let additions = file.additions, let deletions = file.deletions {
            parts.append("\(additions) linhas adicionadas")
            parts.append("\(deletions) removidas")
        } else {
            parts.append("arquivo binário")
        }
        return parts.joined(separator: ", ")
    }
}

extension AtlasCodeFileRow {
    var lead: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: symbol)
                .atlasSans(8.5, .bold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 17, height: 17)
                .background(AtlasTheme.surfaceHi, in: RoundedRectangle(cornerRadius: 5))
                .accessibilityHidden(true)

            fileNameStack

            Spacer(minLength: 8)

            diffStats
        }
    }
}

extension AtlasCodeFileRow {
    var fileNameStack: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(file.fileName)
                .atlasSans(12.5, .medium)
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
            if let subtitle {
                Text(subtitle)
                    .font(AtlasFont.mono(8.5))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.head)
            }
        }
        .accessibilityHidden(true)
    }
}

extension AtlasCodeFileRow {
    @ViewBuilder
    var diffStats: some View {
        if let additions = file.additions, let deletions = file.deletions {
            Text("+\(additions) \u{2212}\(deletions)")
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        } else {
            Text("binário")
                .font(AtlasFont.mono(8.5))
                .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeFileRowA11y {
    static func verbMutate(for status: AtlasCodeFileStatus) -> String? {
        switch status {
        case .added: return "adicionado"
        case .modified: return "alterado"
        case .deleted: return "removido"
        default: return nil
        }
    }
}

extension AtlasCodeFileRowA11y {
    static func verbRenameCopy(for status: AtlasCodeFileStatus) -> String? {
        switch status {
        case .renamed: return "renomeado"
        case .copied: return "copiado"
        default: return nil
        }
    }
}

extension AtlasCodeFileRowA11y {
    static func verbTransform(for status: AtlasCodeFileStatus) -> String {
        if let rename = verbRenameCopy(for: status) { return rename }
        switch status {
        case .typeChanged: return "tipo alterado"
        case .unknown: return "mudança desconhecida"
        default: return verbMutate(for: status) ?? "mudança desconhecida"
        }
    }
}

extension AtlasCodeFileRowA11y {
    static func verb(for status: AtlasCodeFileStatus) -> String {
        verbMutate(for: status) ?? verbTransform(for: status)
    }
}

extension AtlasCodeFileRow {
    var subtitle: String? {
        if let from = file.renamedFrom { return "de \(from)" }
        return file.directory
    }
}

extension AtlasCodeFileRow {
    var symbolMutate: String? {
        switch file.status {
        case .added: return "plus"
        case .modified: return "pencil"
        case .deleted: return "minus"
        default: return nil
        }
    }
}

extension AtlasCodeFileRow {
    var symbolTransform: String? {
        switch file.status {
        case .renamed: return "arrow.right"
        case .copied: return "doc.on.doc"
        case .typeChanged: return "arrow.triangle.2.circlepath"
        default: return nil
        }
    }
}

extension AtlasCodeFileRow {
    var symbol: String {
        symbolMutate ?? symbolTransform ?? "questionmark"
    }
}


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
                .accessibilityHint(active ? "filtro ativo do grafo" : "filtra commits do grafo")
                .accessibilityAddTraits(active ? [.isButton, .isSelected] : .isButton)
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
                .accessibilityAddTraits(.isButton)
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


/// H6 · a âncora do grafo.
///
/// Isto NÃO é o estado de uma conversa — a conversa é a `ConversationModel`, no
/// card. Aqui vive só a última leitura determinística do git: os commits que a
/// resposta citou, que o grafo acende atrás do vidro. Um grafo não tem duas
/// verdades ao mesmo tempo; perguntar de novo substitui, não empilha.
///
/// A divisão de trabalho: este model LÊ o git e ancora o mapa; o agente ENTENDE
/// e responde. Os fatos daqui viajam no fio como prefixo da pergunta.
@Observable
@MainActor
final class AtlasCodeAskModel {
    enum Phase: Equatable {
        case idle
        case answered(AtlasCodeAskResponse)
    }

    let client: AtlasClient
    private(set) var repo: String
    private(set) var phase: Phase = .idle

    init(client: AtlasClient, repo: String) {
        self.client = client
        self.repo = repo
    }

    func adoptRepo(_ newRepo: String) {
        guard newRepo != repo else { return }
        repo = newRepo
        phase = .idle
    }

    /// Os commits que a resposta atual cita. O grafo acende só estes.
    var anchors: Set<String> {
        if case .answered(let response) = phase { return response.anchorSet }
        return []
    }

    /// Verdadeiro quando há resposta apontando para commits: o grafo então
    /// apaga o resto, porque a resposta é o assunto.
    var isAnchoring: Bool { !anchors.isEmpty }

    /// A legenda do recorte: "12 de 43 acesos no grafo".
    ///
    /// Um mapa com 3/4 da história a 0.26 de opacidade e nenhuma frase dizendo
    /// o porquê lê como "é só isso" — que é mentira sobre o repositório. O
    /// servidor calcula `commits_total` e `truncated` exatamente para esta
    /// frase existir, e ela estava escrita e morta: `anchorNote` não tinha um
    /// único chamador no app inteiro. Contrato dos dois lados, faltando o Text.
    var anchorNote: String? {
        if case .answered(let response) = phase { return response.anchorNote }
        return nil
    }

    /// Limpar apaga a âncora: o grafo volta a mostrar tudo.
    func clear() {
        phase = .idle
    }

    /// Os fatos de um turno da conversa, para o agente ler antes de responder.
    ///
    /// Efeito colateral deliberado: a mesma leitura ancora o grafo. Quando o
    /// card fecha, o mapa atrás já está aceso nos commits que sustentaram a
    /// resposta — perguntar move a topologia, que é o ponto da tela.
    ///
    /// `nil` quando o determinístico não sabe (julgamento não é filtro de git) e
    /// quando a rede cai: o agente responde sem muleta, e falha de rede nunca
    /// vira fato inventado com ar de autoridade.
    ///
    /// `answered` é o que decide se a topologia se move, e a distinção é fina:
    /// - `answered == false` → o git NÃO foi lido (julgamento, ou git mudo).
    ///   A leitura não tem opinião sobre o mapa, então o mapa fica como está.
    ///   Sem esta guarda, "explica melhor" — a coisa mais natural do mundo num
    ///   card de conversa — apagava em silêncio a resposta anterior, e a tese
    ///   da tela sobrevivia a exatamente um turno.
    /// - `answered == true` com zero commits → o git FOI lido e não há o que
    ///   acender ("nada mudou hoje"). Aí a âncora morre mesmo: a leitura nova é
    ///   a verdade nova, e segurar o mapa velho seria mentir com mapa.
    ///
    /// É a mesma guarda de `AtlasCodeFacts.block`: quem não leu não afirma.
    func facts(for question: String) async -> String? {
        guard let response = try? await client.askCode(repo: repo, question: question, mode: .facts),
              response.answered
        else { return nil }
        phase = .answered(response)
        return AtlasCodeFacts.block(from: response)
    }
}


// Troca de repositório no grafo — mesmo vocabulário visual do picker da home
// (AtlasTheme.bg, card, gesto pra fechar). Sem scan de violações (rápido).

struct AtlasCodeRepoPickerSheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var model: AtlasCodeWorkspaceModel
    let currentRepo: String
    let onPick: (String) -> Void

    init(client: AtlasClient, currentRepo: String, onPick: @escaping (String) -> Void) {
        let catalog = AtlasCodeWorkspaceModel(client: client)
        catalog.seedFromCache()
        _model = State(initialValue: catalog)
        self.currentRepo = currentRepo
        self.onPick = onPick
    }

    var body: some View {
        NavigationStack {
            Group {
                switch model.phase {
                case .loaded:
                    if let workspace = model.workspace, workspace.repositoryCount > 0 {
                        repoScroll(workspace)
                    } else {
                        ContentUnavailableView(
                            "sem repositórios",
                            systemImage: "folder",
                            description: Text("o workspace não publicou nenhum repo")
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("sem repositórios, o workspace não publicou nenhum repo")
                    }
                case .failed:
                    ContentUnavailableView(
                        "não consegui ler a frota",
                        systemImage: "wifi.slash",
                        description: Text("tente de novo em instantes")
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("não consegui ler a frota, tente de novo em instantes")
                default:
                    VStack(spacing: 12) {
                        BreathingDiamond(size: 10, reduceMotion: reduceMotion)
                        Text("lendo os repositórios do Mac…")
                            .font(AtlasFont.serifItalic(15))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("lendo os repositórios do Mac")
                    .accessibilityAddTraits(reduceMotion ? .isStaticText : [.isStaticText, .updatesFrequently])
                }
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Repositório")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                Text("Repositório")
                    .font(AtlasFont.serif(18))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    .accessibilityAddTraits(.isHeader)
            }
            .task {
                // Cache hit → phase já .loaded; miss → uma ida à rede.
                if model.phase == .idle { await model.loadStructure() }
            }
            .accessibilityIdentifier(A11yID.codeRepoPicker)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AtlasTheme.bg)
    }

    private func repoScroll(_ workspace: AtlasCodeWorkspaceResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if !workspace.recents.isEmpty {
                    section("recentes", repos: workspace.recents)
                }
                ForEach(workspace.folders) { folder in
                    section(folder.name, repos: folder.repos)
                }
                if !workspace.loose.isEmpty {
                    section("avulsos", repos: workspace.loose)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 12)
            .padding(.bottom, 28)
        }
    }

    private func section(_ title: String, repos: [AtlasCodeRepoRef]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(AtlasFont.mono(11, .medium))
                .tracking(1.6)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(title)
            VStack(spacing: 0) {
                ForEach(Array(repos.enumerated()), id: \.element.id) { index, repo in
                    repoRow(repo)
                    if index < repos.count - 1 {
                        Divider().overlay(AtlasTheme.separatorSoft)
                    }
                }
            }
            .atlasCard()
        }
    }

    private func repoRow(_ repo: AtlasCodeRepoRef) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onPick(repo.slug)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "folder")
                    .atlasSans(15)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Text(repo.name)
                    .atlasSans(15, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 0)
                if repo.slug == currentRepo {
                    Circle()
                        .fill(AtlasTheme.accent)
                        .frame(width: 6, height: 6)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            repo.slug == currentRepo
                ? "\(repo.name), repositório atual"
                : repo.name
        )
        .accessibilityHint(repo.slug == currentRepo ? "já aberto no grafo" : "abre o grafo deste repositório")
        .accessibilityAddTraits(repo.slug == currentRepo ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier(A11yID.codeRepoPickerRow(repo.slug))
    }
}


// Cycle 043 fuse → AtlasCodeHealReceiptSheet.swift

// MARK: - Folha: Recibo de Cura (C25 — fato consumado, só veto)

struct AtlasCodeHealReceiptSheet: View {
    let heal: AtlasCodeHealResponse
    let onUndo: () -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            receiptContent()
        }
        .accessibilityIdentifier(A11yID.codeHealReceiptSheet)
        // Contain without fused sheet label so masthead/steps/undo stay focusable.
        .accessibilityElement(children: .contain)
    }
}

extension AtlasCodeHealReceiptSheet {
    func spokenMastheadLabel() -> String {
        hasCompletedHeal
            ? "curado sozinho, modo \(heal.mode)"
            : "cura, modo \(heal.mode)"
    }

    func spokenSilenceLabel() -> String {
        "você não foi necessário, cura concluída sem portão"
    }
}

extension AtlasCodeHealReceiptSheet {
    func spokenBlockedLabel(_ blocked: String) -> String {
        "cura bloqueada, \(blocked)"
    }

    func spokenEmptyStepsLabel() -> String {
        "recibo sem passos registrados pelo servidor"
    }
}

extension AtlasCodeHealReceiptSheet {
    func spokenStepLabel(_ receipt: AtlasCodeHealStepReceipt) -> String {
        let outcome = receipt.status == "completed" ? "concluído" : "falhou"
        var parts = ["passo \(receipt.step)", receipt.action, outcome]
        if !receipt.result.isEmpty { parts.append(receipt.result) }
        return parts.joined(separator: ", ")
    }

    func spokenUndoWindowLabel(_ note: String) -> String {
        "janela de veto, \(note)"
    }
}

extension AtlasCodeHealReceiptSheet {
    var completedStepCount: Int {
        heal.stepReceipts.filter { $0.status == "completed" }.count
    }

    var hasCompletedHeal: Bool { completedStepCount > 0 }
}

extension AtlasCodeHealReceiptSheet {
    var undoExpiresAt: String? {
        heal.stepReceipts.compactMap(\.undoExpiresAt).first
    }

    var canUndo: Bool {
        heal.healId != nil && AtlasCodeUndoWindow.isOpen(expiresAt: undoExpiresAt)
    }
}

extension AtlasCodeHealReceiptSheet {
    func spokenUndoButtonLabel() -> String {
        canUndo ? "desfazer cura com recibo" : "desfazer indisponível"
    }

    func spokenUndoButtonHint() -> String {
        canUndo
            ? "envia veto retroativo auditável para esta cura"
            : "prazo de veto encerrado ou recibo sem identificador"
    }
}

extension AtlasCodeHealReceiptSheet {
    var masthead: some View {
        HStack(spacing: 7) {
            Image(systemName: hasCompletedHeal ? "checkmark" : "exclamationmark.triangle")
                .atlasSans(10, .bold)
                .accessibilityHidden(true)
            Text(hasCompletedHeal
                 ? "CURADO SOZINHO · \(heal.mode.uppercased())"
                 : "CURA · \(heal.mode.uppercased())")
                .atlasSans(9, .bold)
                .tracking(1.2)
                .accessibilityHidden(true)
        }
        .foregroundStyle(hasCompletedHeal ? AtlasCodePalette.healed : AtlasTheme.textTertiary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenMastheadLabel())
    }
}

extension AtlasCodeHealReceiptSheet {
    @ViewBuilder
    func receiptContent() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            masthead
            healStatusLines
            receiptStepsOrEmpty
            receiptUndoFooter
            Spacer(minLength: 0)
        }
        .padding(22)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: canUndo)
    }
}

extension AtlasCodeHealReceiptSheet {
    @ViewBuilder
    var healStatusLines: some View {
        if hasCompletedHeal {
            Text("você não foi necessário")
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(spokenSilenceLabel())
        }

        if let blocked = heal.blocked, !blocked.isEmpty {
            Text("bloqueado · \(blocked)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasCodePalette.alert)
                .accessibilityLabel(spokenBlockedLabel(blocked))
        }
    }
}

extension AtlasCodeHealReceiptSheet {
  @ViewBuilder
  func stepCopy(_ receipt: AtlasCodeHealStepReceipt) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(receipt.action)
        .atlasSans(13)
        .foregroundStyle(AtlasTheme.textPrimary)
        .accessibilityHidden(true)
      if !receipt.result.isEmpty {
        Text(receipt.result)
          .font(AtlasFont.mono(9))
          .foregroundStyle(AtlasTheme.textTertiary)
          .accessibilityHidden(true)
      }
    }
  }
}

extension AtlasCodeHealReceiptSheet {
  @ViewBuilder
  func stepRow(index: Int, receipt: AtlasCodeHealStepReceipt) -> some View {
    HStack(alignment: .top, spacing: 9) {
      Image(systemName: receipt.status == "completed" ? "checkmark" : "xmark")
        .atlasSans(10, .semibold)
        .foregroundStyle(receipt.status == "completed" ? AtlasCodePalette.healed : AtlasCodePalette.alert)
        .padding(.top, 2)
        .accessibilityHidden(true)
      stepCopy(receipt)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(spokenStepLabel(receipt))
    .accessibilityIdentifier(A11yID.codeHealStep(index))
  }
}

extension AtlasCodeHealReceiptSheet {
  @ViewBuilder
  func stepsBlock() -> some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(Array(heal.stepReceipts.enumerated()), id: \.element.id) { index, receipt in
        stepRow(index: index, receipt: receipt)
      }
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
    // Contain without fused label: each step row stays focusable.
    .accessibilityElement(children: .contain)
  }
}

extension AtlasCodeHealReceiptSheet {
    @ViewBuilder
    var receiptStepsOrEmpty: some View {
        if heal.stepReceipts.isEmpty {
            Text("sem passos registrados no recibo")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel(spokenEmptyStepsLabel())
        } else {
            stepsBlock()
        }
    }
}

extension AtlasCodeHealReceiptSheet {
    var undoButton: some View {
        Button {
            // Medium: undo with receipt is governed commit.
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onUndo()
            dismiss()
        } label: {
            undoButtonLabel
        }
        .buttonStyle(PressableScale())
        .transition(reduceMotion ? .identity : .opacity)
        .accessibilityIdentifier(A11yID.codeHealUndo)
        .accessibilityLabel(spokenUndoButtonLabel())
        .accessibilityHint(spokenUndoButtonHint())
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(9)
    }
}

extension AtlasCodeHealReceiptSheet {
    @ViewBuilder
    var receiptUndoFooter: some View {
        if let note = AtlasCodeUndoWindow.note(expiresAt: undoExpiresAt) {
            Text(note)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityIdentifier(A11yID.codeHealUndoWindow)
                .accessibilityLabel(spokenUndoWindowLabel(note))
        }
        if canUndo {
            undoButton
        }
    }
}

extension AtlasCodeHealReceiptSheet {
    var undoButtonLabel: some View {
        HStack(spacing: 7) {
            Image(systemName: "arrow.uturn.backward")
                .accessibilityHidden(true)
            Text("Desfazer — com recibo")
        }
        .atlasSans(14, .medium)
        .frame(maxWidth: .infinity, minHeight: 48)
        .padding(.vertical, 12)
        .foregroundStyle(AtlasTheme.textSecondary)
        .contentShape(Rectangle())
        .atlasCard(cornerRadius: 13)
    }
}
