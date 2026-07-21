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
            reduceMotion ? nil : .easeInOut(duration: AtlasMotion.instinct),
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
                    .font(AtlasFont.serif(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(minHeight: 48, alignment: .center)
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
                    .font(AtlasFont.serif(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(minHeight: 48, alignment: .center)
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
                    .font(AtlasFont.serif(13, .semibold))
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .atlasSans(9, .semibold)
                    .opacity(0.55)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
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
                .animation(reduceMotion ? nil : .easeInOut(duration: AtlasMotion.ceremonial), value: model.scanState)
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
                .font(AtlasFont.mono(10, .semibold))
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
                    withAnimation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct)) {
                        graphStateFilter = option
                    }
                } label: {
                    VStack(spacing: 8) {
                        HStack(spacing: 3) {
                            Text(option.label)
                                .font(active ? AtlasFont.serif(12, .semibold) : AtlasFont.serif(12))
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
                    .frame(maxWidth: .infinity, minHeight: 48)
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
        .animation(reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct), value: graphStateFilter)
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
            reduceMotion ? nil : .easeInOut(duration: AtlasMotion.considered),
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
            Text(title)
                .font(AtlasFont.serif(13, .semibold))
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
                 ? "Curado sozinho · \(heal.mode)"
                 : "Cura · \(heal.mode)")
                .font(AtlasFont.serif(12, .semibold))
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


// Cycle 043 fuse → AtlasCodeMirrorCard.swift

/// M5 · Espelho — o que sairia do Mac, e o que a varredura encontrou.
struct AtlasCodeMirrorCard: View {
    let response: AtlasCodeMirrorResponse
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        mirrorCardChrome
    }
}

extension AtlasCodeMirrorCard {
    var mirrorStatePhaseCountedID: String? {
        switch response.state {
        case .pending(let commits): return "pending-\(commits)"
        case .blocked(let rules): return "blocked-\(rules.joined(separator: "-"))"
        default: return nil
        }
    }
}

extension AtlasCodeMirrorCard {
    var mirrorStatePhaseQuietID: String? {
        switch response.state {
        case .mirrored: return "mirrored"
        case .noMirror: return "no-mirror"
        case .unknown: return "unknown"
        default: return nil
        }
    }
}

extension AtlasCodeMirrorCard {
    var mirrorStatePhaseID: String {
        mirrorStatePhaseCountedID
            ?? mirrorStatePhaseQuietID
            ?? "unknown"
    }
}

/// Só fala host e contagens reais do payload; ausência nunca vira zero fabricado.

extension AtlasCodeMirrorCard {
    func spokenMirrorLabel() -> String {
        var parts: [String] = ["Espelho"]
        parts.append(contentsOf: spokenMirrorStateParts())
        if let host = response.mirror?.host, !host.isEmpty {
            parts.append("host \(host)")
        }
        return parts.joined(separator: ", ")
    }

    static let mirrorHint = "cópia remota do repositório e varredura de segredos no Mac"
}

extension AtlasCodeMirrorCard {
    var mirrorCardChrome: some View {
        VStack(alignment: .leading, spacing: 8) {
            mirrorHeader
            headline
            blockedRulesRow
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background, in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.card))
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).strokeBorder(borderColor, lineWidth: 1))
        .animation(reduceMotion ? nil : .easeInOut(duration: AtlasMotion.considered), value: mirrorStatePhaseID)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenMirrorLabel())
        .accessibilityHint(Self.mirrorHint)
        .accessibilityIdentifier(A11yID.codeMirror)
    }
}

extension AtlasCodeMirrorCard {
    var mirrorHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("Espelho")
                .font(AtlasFont.serif(18, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Spacer()
            if let host = response.mirror?.host {
                Text(host)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var blockedRulesRow: some View {
        if case .blocked(let rules) = response.state {
            HStack(spacing: 5) {
                ForEach(rules, id: \.self) { rule in
                    Text(rule)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasCodePalette.alert)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .overlay(Capsule().strokeBorder(AtlasCodePalette.alert.opacity(0.3), lineWidth: 1))
                        .accessibilityHidden(true)
                }
            }
            .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeMirrorCard {
    var background: Color {
        if case .blocked = response.state { return AtlasCodePalette.alert.opacity(0.05) }
        return AtlasTheme.surface.opacity(0.4)
    }

    var borderColor: Color {
        if case .blocked = response.state { return AtlasCodePalette.alert.opacity(0.35) }
        return AtlasTheme.separator
    }
}

extension AtlasCodeMirrorCard {
    func label(_ text: String, color: Color, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            Text(text)
                .atlasSans(12.5)
                .accessibilityHidden(true)
        }
        .foregroundStyle(color)
        .accessibilityHidden(true)
    }
}

extension AtlasCodeMirrorCard {
    func spokenMirrorBlockedParts(rules: [String]) -> [String] {
        var parts = ["bloqueado, segredo detectado"]
        if !rules.isEmpty {
            parts.append("regras \(rules.joined(separator: ", "))")
        }
        return parts
    }
}

extension AtlasCodeMirrorCard {
    func spokenMirrorPendingParts(commits: Int) -> [String] {
        ["\(commits) commit\(commits == 1 ? "" : "s") ainda só no Mac"]
    }
}

extension AtlasCodeMirrorCard {
    func spokenMirrorMirroredParts() -> [String]? {
        if case .mirrored = response.state {
            return ["tudo espelhado, verdade no Mac"]
        }
        return nil
    }
}

extension AtlasCodeMirrorCard {
    func spokenMirrorQuietParts() -> [String]? {
        if let mirrored = spokenMirrorMirroredParts() { return mirrored }
        switch response.state {
        case .noMirror:
            return ["sem espelho configurado"]
        case .unknown:
            return ["estado ainda não conhecido"]
        default:
            return nil
        }
    }
}

extension AtlasCodeMirrorCard {
    func spokenMirrorStateParts() -> [String] {
        if let quiet = spokenMirrorQuietParts() { return quiet }
        switch response.state {
        case .pending(let commits):
            return spokenMirrorPendingParts(commits: commits)
        case .blocked(let rules):
            return spokenMirrorBlockedParts(rules: rules)
        default:
            return ["estado ainda não conhecido"]
        }
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineBlocked: some View {
        if case .blocked = response.state {
            label(
                "segredo detectado · nada sai da máquina",
                color: AtlasCodePalette.alert,
                icon: "exclamationmark.triangle"
            )
        }
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyActive: some View {
        switch response.state {
        case .mirrored:
            headlineHealthyMirrored
        case .pending(let commits):
            headlineHealthyPending(commits: commits)
        default:
            EmptyView()
        }
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyMirrored: some View {
        label("tudo espelhado · a verdade fica no Mac", color: AtlasTheme.textSecondary, icon: "checkmark")
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    func headlineHealthyPending(commits: Int) -> some View {
        label(
            commits == 1 ? "1 commit ainda só no Mac" : "\(commits) commits ainda só no Mac",
            color: AtlasTheme.textSecondary,
            icon: "internaldrive"
        )
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyNoMirror: some View {
        label("sem espelho configurado", color: AtlasTheme.textTertiary, icon: "circle.dashed")
    }

    @ViewBuilder
    var headlineHealthyUnknown: some View {
        label("espelho ainda não conhecido", color: AtlasTheme.textTertiary, icon: "questionmark.circle")
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyQuiet: some View {
        switch response.state {
        case .noMirror:
            headlineHealthyNoMirror
        case .unknown:
            headlineHealthyUnknown
        default:
            EmptyView()
        }
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthy: some View {
        switch response.state {
        case .mirrored, .pending:
            headlineHealthyActive
        case .noMirror, .unknown:
            headlineHealthyQuiet
        default:
            EmptyView()
        }
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headline: some View {
        headlineBlocked
        headlineHealthy
    }
}


/// M5 · Espelho — fetch model; card em `AtlasCodeMirrorCard.swift`.
@MainActor
@Observable
final class AtlasCodeMirrorModel {
    private let client: AtlasClient
    private(set) var repo: String
    private(set) var response: AtlasCodeMirrorResponse?

    init(client: AtlasClient, repo: String) {
        self.client = client
        self.repo = repo
    }

    func adoptRepo(_ newRepo: String) {
        guard newRepo != repo else { return }
        repo = newRepo
        response = nil
    }

    func refresh() async {
        // Sem resposta, a seção não fala — ausência nunca vira "0 a espelhar".
        //
        // E falha NÃO APAGA a leitura anterior: `response = try?` zerava o
        // card no primeiro fetch que caísse, e o estado que mais precisa de
        // olho — espelho BLOQUEADO POR SEGREDO — sumia da tela por causa de
        // uma queda de rede. O alarme aceso fica aceso até uma leitura REAL
        // dizer o contrário; só resposta nova escreve o estado.
        if let fresh = try? await client.getCodeMirror(repo: repo) {
            response = fresh
        }
    }
}


// Cycle 043 fuse → AtlasCodeWhySheet.swift

struct AtlasCodeWhySheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var model: AtlasCodeWhyModel
    let repo: String
    let file: String

    init(client: AtlasClient, repo: String, file: String) {
        _model = State(initialValue: AtlasCodeWhyModel(client: client))
        self.repo = repo
        self.file = file
    }

    var body: some View {
        whyLifecycleA11y(whyBodyShell)
    }
}

extension AtlasCodeWhySheet {
    var whyContentLoadedID: String {
        guard let why = model.why else { return "loaded-nil" }
        return why.commits.isEmpty ? "empty" : "timeline-\(why.commits.count)"
    }
}

extension AtlasCodeWhySheet {
    var whyContentPhaseID: String {
        switch model.phase {
        case .idle, .loading: return "loading"
        case .failed: return "failed"
        case .loaded: return whyContentLoadedID
        }
    }
}

extension AtlasCodeWhySheet {
    func spokenCommit(_ commit: AtlasCodeWhy.Commit) -> String {
        var parts: [String] = []
        if let quote = commit.provenance?.quote, !quote.isEmpty {
            parts.append(quote)
        } else {
            parts.append("sem proveniência registrada")
        }
        parts.append(commit.agentLabel)
        if let when = commit.when {
            parts.append("há \(AtlasCodeRelativeTime.short(from: Int(when.timeIntervalSince1970)))")
        }
        parts.append(commit.shortHash)
        if let obra = commit.provenance?.obra, !obra.isEmpty { parts.append(obra) }
        if !commit.subject.isEmpty { parts.append(commit.subject) }
        return parts.joined(separator: ", ")
    }

    static let sheetHint = "histórico de commits e proveniência registrada pelo Atlas"
}

extension AtlasCodeWhySheet {
    func spokenLoading() -> String { "lendo a história do arquivo" }

    func spokenFailed() -> String {
        if let message = model.message, !message.isEmpty {
            return "biografia indisponível, \(message)"
        }
        return "biografia indisponível"
    }

    func spokenEmptyHistory() -> String { "este arquivo não tem história neste recorte" }
}

extension AtlasCodeWhySheet {
    var whyBodyShell: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            whyScrollBody
        }
    }
}

extension AtlasCodeWhySheet {
    @ViewBuilder var whyBusyContent: some View {
        switch model.phase {
        case .idle, .loading, .failed:
            whyLoadingOrFailed
        default:
            EmptyView()
        }
    }
}

extension AtlasCodeWhySheet {
    @ViewBuilder var content: some View {
        switch model.phase {
        case .idle, .loading, .failed:
            whyBusyContent
        case .loaded:
            if let why = model.why {
                whyLoadedCommits(why)
            }
        }
    }
}

extension AtlasCodeWhySheet {
    @ViewBuilder
    func whyLoadedCommits(_ why: AtlasCodeWhy) -> some View {
        if why.commits.isEmpty {
            Text("este arquivo não tem história neste recorte")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.top, 6)
                .accessibilityLabel(spokenEmptyHistory())
                .accessibilityAddTraits(.isHeader)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(why.commits.enumerated()), id: \.element.id) { index, commit in
                    whyRow(commit, index: index, isLast: index == why.commits.count - 1)
                }
            }
        }
    }
}

extension AtlasCodeWhySheet {
    var whyFailed: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("biografia indisponível")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            if let message = model.message, !message.isEmpty {
                Text(message)
                    .font(AtlasFont.mono(9.5))
                    .foregroundStyle(AtlasCodePalette.alert)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenFailed())
        .accessibilityAddTraits(.isHeader)
    }
}

extension AtlasCodeWhySheet {
    @ViewBuilder
    var headerTruncation: some View {
        if let why = model.why, why.truncated {
            Text("mostrando \(why.commits.count) de \(why.commitsTotal) · história truncada")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeWhySheet {
    func whyLifecycleA11y<V: View>(_ content: V) -> some View {
        content
            .task { if model.phase == .idle { await model.load(repo: repo, file: file) } }
            .accessibilityIdentifier(A11yID.whySheet)
            // Contain without fused sheet label so history rows stay focusable.
            .accessibilityElement(children: .contain)
    }
}

extension AtlasCodeWhySheet {
    @ViewBuilder
    var whyLoadingOrFailed: some View {
        switch model.phase {
        case .idle, .loading:
            whyLoading
        case .failed:
            whyFailed
        default:
            EmptyView()
        }
    }
}

extension AtlasCodeWhySheet {
    var whyLoading: some View {
        HStack(spacing: 10) {
            BreathingDiamond(size: 10, reduceMotion: reduceMotion)
                .accessibilityHidden(true)
            Text("lendo a história do arquivo…")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(.top, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLoading())
        .accessibilityAddTraits(reduceMotion ? .isStaticText : [.isStaticText, .updatesFrequently])
    }
}

extension AtlasCodeWhySheet {
    @ViewBuilder
    func whyRowConnector(isLast: Bool) -> some View {
        if !isLast {
            Rectangle()
                .fill(AtlasTheme.accent.opacity(0.35))
                .frame(width: 1)
                .frame(minHeight: 56)
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeWhySheet {
    func whyRowRail(isLast: Bool) -> some View {
        VStack(spacing: 0) {
            Circle()
                .fill(AtlasTheme.accent)
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)
            whyRowConnector(isLast: isLast)
        }
        .padding(.top, 7)
        .accessibilityHidden(true)
    }
}

extension AtlasCodeWhySheet {
    func meta(for commit: AtlasCodeWhy.Commit) -> String {
        var parts = [commit.agentLabel]
        if let when = commit.when {
            parts.append("há \(AtlasCodeRelativeTime.short(from: Int(when.timeIntervalSince1970)))")
        }
        parts.append(commit.shortHash)
        if let obra = commit.provenance?.obra, !obra.isEmpty { parts.append(obra) }
        return parts.joined(separator: " · ")
    }
}

extension AtlasCodeWhySheet {
    @ViewBuilder
    func whyRowQuote(_ commit: AtlasCodeWhy.Commit) -> some View {
        if let quote = commit.provenance?.quote {
            Text("\u{201C}\(quote)\u{201D}")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
        } else {
            Text("sem proveniência registrada")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeWhySheet {
    func whyRowText(_ commit: AtlasCodeWhy.Commit, isLast: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            whyRowQuote(commit)
            Text(meta(for: commit))
                .font(AtlasFont.mono(10.5))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(commit.subject)
                .atlasSans(11)
                .foregroundStyle(AtlasTheme.textSecondary.opacity(0.75))
                .lineLimit(2)
                .accessibilityHidden(true)
        }
        .padding(.bottom, isLast ? 0 : 18)
    }
}

extension AtlasCodeWhySheet {
    func whyRow(_ commit: AtlasCodeWhy.Commit, index: Int, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            whyRowRail(isLast: isLast)
            whyRowText(commit, isLast: isLast)
        }
        .frame(minHeight: 56, alignment: .top)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenCommit(commit))
        .accessibilityIdentifier(A11yID.whyRow(index))    }
}

extension AtlasCodeWhySheet {
    var whyScrollBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: whyContentPhaseID)
        }
    }
}

extension AtlasCodeWhySheet {
    var whyHeaderSpokenLabel: String {
        guard let why = model.why, why.truncated else { return file }
        return "\(file), mostrando \(why.commits.count) de \(why.commitsTotal)"
    }
}

extension AtlasCodeWhySheet {
    var whyHeaderTitleBlock: some View {
        Group {
            Text("POR QUE ESTE ARQUIVO EXISTE")
                .atlasSans(9, .semibold)
                .tracking(1.5)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(file)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .truncationMode(.middle)
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeWhySheet {
    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            whyHeaderTitleBlock
            headerTruncation
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(whyHeaderSpokenLabel)
    }
}


@MainActor
@Observable
final class AtlasCodeWhyModel {
    private let client: AtlasClient
    private(set) var phase: LoadPhase = .idle
    private(set) var why: AtlasCodeWhy?
    private(set) var message: String?
    private var wanted: String?

    init(client: AtlasClient) {
        self.client = client
    }

    func load(repo: String, file: String) async {
        let key = "\(repo)\n\(file)"
        wanted = key
        phase = .loading
        message = nil
        do {
            let response = try await client.getCodeWhy(repo: repo, file: file)
            guard wanted == key else { return }
            why = response
            phase = .loaded
        } catch {
            guard wanted == key else { return }
            message = String(describing: error)
            phase = .failed(message ?? "falha desconhecida")
        }
    }
}


// Cycle 044 fuse → AtlasCodeProvenanceSheet.swift

// MARK: - Folha: por que esta linha existe (C23)

/// Alvo do sheet “por quê” a partir de um path de arquivo da proveniência.
struct AtlasCodeProvenanceWhyTarget: Identifiable {
    let path: String
    var id: String { path }
}

/// A folha responde, em ordem, as perguntas de quem abre um commit: em que
/// estado ele está, o que ele diz, por que existe, e o que ele tocou.
/// O hash fecha a folha — máquina embaixo do vidro (lei 6).
struct AtlasCodeProvenanceSheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var whyTarget: AtlasCodeProvenanceWhyTarget?
    let client: AtlasClient
    let repo: String
    let node: AtlasCodeGraphNode
    let state: AtlasCodeNodeState
    let ruleId: String?
    /// O doc que sustenta a acusação. Ausente = a regra ainda não tem lei
    /// escrita, e isso é dito calando — nunca com um caminho plausível.
    let ruleCanon: String?
    /// A trunk real — a lei citada fala o nome da linha, nunca "main" no chute.
    let trunk: String?
    let phase: AtlasCodeProvenanceModel.Phase
    /// A saída do beco: daqui o operador fala com o agente SOBRE este commit.
    let onAsk: () -> Void

    var body: some View {
        provenanceBodyShell
    }
}

extension AtlasCodeProvenanceSheet {
    func hasLoadedBody(_ provenance: AtlasCodeProvenance) -> Bool {
        provenance.commitBody?.nonEmpty != nil
            || provenance.operatorQuote?.nonEmpty != nil
            || !(provenance.gates?.isEmpty ?? true)
            || !(provenance.obra?.isEmpty ?? true)
            || !provenance.files.isEmpty
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceLoadedPhaseID(_ provenance: AtlasCodeProvenance) -> String {
        hasLoadedBody(provenance) ? "loaded-\(provenance.files.count)" : "loaded-empty"
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceContentPhaseID: String {
        switch phase {
        case .idle, .loading: return "loading"
        case .failed: return "failed"
        case .loaded(let provenance):
            return provenanceLoadedPhaseID(provenance)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func spokenLoading() -> String { "lendo proveniência do commit" }

    func spokenFailed(_ message: String) -> String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "proveniência indisponível" }
        return "proveniência indisponível, \(trimmed)"
    }

    static let sheetHint = "estado do commit, lei aplicável e o que o ledger registrou"
    static let askHint = "abre conversa com este commit no assunto"
}

extension AtlasCodeProvenanceSheet {
    func spokenStateKickerHealthy() -> String? {
        switch state {
        case .onMain: return "na \(trunk?.nonEmpty ?? "main")"
        case .healed: return "curado"
        default: return nil
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func spokenStateKicker() -> String {
        if let healthy = spokenStateKickerHealthy() { return healthy }
        switch state {
        case .violating: return "fora da \(trunk?.nonEmpty ?? "main")"
        case .history: return "história"
        default: return "história"
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func spokenHeaderTitle() -> String {
        node.message?.nonEmpty ?? String(node.hash.prefix(8))
    }
}

extension AtlasCodeProvenanceSheet {
    func spokenLawCitation() -> String? {
        guard state == .violating, let ruleId else { return nil }
        var parts = [AtlasCodeIssue.law(ruleId, trunk: trunk)]
        if let ruleCanon = ruleCanon?.nonEmpty { parts.append(ruleCanon) }
        return parts.joined(separator: ", ")
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceBodyShell: some View {
        provenanceSheetChrome(provenanceSurface)
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceSheetChrome<Content: View>(_ content: Content) -> some View {
        content
            // Contain without fused label: ask / why file rows stay focusable.
            .accessibilityElement(children: .contain)
            .accessibilityHint(Self.sheetHint)
            .sheet(item: $whyTarget) { target in
                AtlasCodeWhySheet(client: client, repo: repo, file: target.path)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceScrollStack: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                lawCitation
                askButton
                provenanceContent(whyTarget: $whyTarget)
                hashFooter
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
            .padding(.bottom, 12)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: provenanceContentPhaseID)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceSurface: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            provenanceScrollStack
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceSheetLoadedParts(_ provenance: AtlasCodeProvenance) -> [String] {
        if let headline = provenance.diffHeadline { return [headline] }
        if !hasLoadedBody(provenance) { return ["ledger sem detalhe neste recorte"] }
        return []
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceSheetPhaseParts() -> [String] {
        switch phase {
        case .idle, .loading:
            return [spokenLoading()]
        case .failed(let message):
            return [spokenFailed(message)]
        case .loaded(let provenance):
            return provenanceSheetLoadedParts(provenance)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceSheetSpokenLabel: String {
        var parts = ["proveniência do commit", spokenHeaderTitle(), spokenStateKicker()]
        parts.append(contentsOf: provenanceSheetPhaseParts())
        return parts.joined(separator: ", ")
    }
}


@MainActor
@Observable
final class AtlasCodeProvenanceModel {
    enum Phase: Equatable {
        case idle, loading, loaded(AtlasCodeProvenance), failed(String)
    }

    let client: AtlasClient
    private(set) var repo: String
    private(set) var phase: Phase = .idle
    /// O commit que a folha ABERTA pediu. Resposta de pedido velho não grava.
    private var wanted: String?

    init(client: AtlasClient, repo: String) {
        self.client = client
        self.repo = repo
    }

    func adoptRepo(_ newRepo: String) {
        guard newRepo != repo else { return }
        repo = newRepo
        phase = .idle
        wanted = nil
    }

    func load(hash: String) async {
        // A corrida real: o operador toca no commit A, fecha, toca no B — e a
        // resposta de A chega DEPOIS da de B. Sem correlacionar, a folha do B
        // mostrava a proveniência do A: autor, arquivos e "sua frase" do commit
        // errado, na tela em que o operador decide se apaga trabalho. Só a
        // resposta do pedido mais recente pode escrever o estado.
        wanted = hash
        phase = .loading
        do {
            let provenance = try await client.getCodeProvenance(hash: hash, repo: repo)
            guard wanted == hash else { return }
            phase = .loaded(provenance)
        } catch {
            guard wanted == hash else { return }
            phase = .failed(String(describing: error))
        }
    }
}


// Cycle 044 fuse → AtlasCodeProvenanceHeader.swift

// MARK: - Cabeçalho da folha de proveniência (C23)

extension AtlasCodeProvenanceSheet {
    var header: some View {
        VStack(alignment: .leading, spacing: 9) {
            headerStateKicker
            headerTitle
            headerDatelineBlock
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isHeader)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension AtlasCodeProvenanceSheet {
    var stateLabelHealthy: String? {
        switch state {
        case .onMain: return "Na main"
        case .healed: return "Curado"
        default: return nil
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var stateLabelViolating: String {
        ruleId.map { "Fora da linha · \(AtlasCodeIssue.law($0, trunk: trunk))" } ?? "Fora da linha"
    }
}

extension AtlasCodeProvenanceSheet {
    var stateLabel: String {
        if let healthy = stateLabelHealthy { return healthy }
        switch state {
        case .violating: return stateLabelViolating
        case .history: return "História"
        default: return "História"
        }
    }
}

extension AtlasCodeProvenanceSheet {
    /// Autor · agente · quando. O agente só aparece quando o ledger respondeu.
    var dateline: String {
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        var parts = [author]
        if case .loaded(let provenance) = phase, !provenance.agent.isEmpty {
            parts.append(provenance.agentLabel)
        }
        parts.append("há \(AtlasCodeRelativeTime.short(from: node.authoredAt))")
        return parts.joined(separator: " · ")
    }
}

extension AtlasCodeProvenanceSheet {
    var headerStateKickerGlyph: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(AtlasCodePalette.color(for: state))
                .frame(width: 6, height: 6)
                .accessibilityHidden(true)
            Text(stateLabel)
                .font(AtlasFont.serif(12, .semibold))
                .foregroundStyle(AtlasCodePalette.color(for: state))
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var headerStateKicker: some View {
        headerStateKickerGlyph
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenStateKicker())
            .accessibilityIdentifier(A11yID.codeProvenanceState)
    }
}

// o bloco composto sumiu). Fiel ao original pré-merge: dateline em mono +
// a magnitude do commit cedo (diffHeadline), nunca escondida pela descrição.

extension AtlasCodeProvenanceSheet {
    var headerDatelineBlock: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(dateline)
                .font(AtlasFont.mono(9.5))
                .foregroundStyle(AtlasTheme.textTertiary)
            if case .loaded(let provenance) = phase, let headline = provenance.diffHeadline {
                Text(headline)
                    .font(AtlasFont.mono(9.5))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
            }
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var hashFooter: some View {
        Text(node.hash)
            .font(AtlasFont.mono(9))
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
            .textSelection(.enabled)
            .padding(.top, 2)
            .accessibilityLabel("hash do commit")
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var headerTitle: some View {
        Group {
            if let message = node.message?.nonEmpty {
                Text(message)
                    .font(AtlasFont.serif(22, .semibold))
            } else {
                Text(String(node.hash.prefix(8)))
                    .font(AtlasFont.mono(22, .semibold))
            }
        }
        .foregroundStyle(AtlasTheme.textPrimary)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityLabel(spokenHeaderTitle())
    }
}


// Cycle 044 fuse → AtlasCodeProvenanceSections.swift

// MARK: - Seções da folha de proveniência (C23)

extension AtlasCodeProvenanceSheet {
    /// A lei que sustenta a acusação — e o documento que a prova.
    @ViewBuilder
    var lawCitation: some View {
        lawCitationChrome
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var askButtonLabelLead: some View {
        Text("✦")
            .font(AtlasFont.serif(12))
            .foregroundStyle(AtlasTheme.accent)
            .accessibilityHidden(true)
        Text("perguntar sobre este commit")
            .font(AtlasFont.serifItalic(14))
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var askButtonLabelTrailing: some View {
        Spacer(minLength: 0)
        Image(systemName: "arrow.up.right")
            .atlasSans(10, .semibold)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    var askButtonLabel: some View {
        HStack(spacing: 8) {
            askButtonLabelLead
            askButtonLabelTrailing
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .frame(minHeight: 48)
        .atlasCard(cornerRadius: AtlasTheme.Radius.control)
        .contentShape(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedDetail(_ message: String) -> some View {
        if let detail = message.nonEmpty {
            Text(detail)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasCodePalette.alert)
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedA11y<Content: View>(_ content: Content, message: String) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenFailed(message))
            .accessibilityAddTraits(.isHeader)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedBody(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            provenanceFailedTitle
            provenanceFailedDetail(message)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedStack(_ message: String) -> some View {
        provenanceFailedA11y(provenanceFailedBody(message), message: message)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var provenanceFailedTitle: some View {
        Text("proveniência indisponível")
            .font(AtlasFont.serifItalic(15))
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailed(_ message: String) -> some View {
        provenanceFailedStack(message)
    }
}

extension AtlasCodeProvenanceSheet {
    /// A porta para o agente, com o commit já no assunto.
    var askButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onAsk()
        } label: {
            askButtonLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityIdentifier(A11yID.codeProvenanceAsk)
        .accessibilityLabel("perguntar ao Atlas sobre este commit")
        .accessibilityHint(Self.askHint)
        .accessibilityAddTraits(.isButton)
    }
}

extension AtlasCodeProvenanceSheet {
    func block(_ title: String, @ViewBuilder body: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(AtlasFont.serif(12, .semibold))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            body()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceLoadingContent: some View {
        TraceEvidenceLoading(text: "lendo o ledger…", reduceMotion: reduceMotion)
            .padding(.top, 2)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceContent(whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>) -> some View {
        switch phase {
        case .idle, .loading:
            provenanceLoadingContent
        case .failed(let message):
            provenanceFailed(message)
        case .loaded(let provenance):
            provenanceLoadedBody(provenance, whyTarget: whyTarget)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceFileButton(
        _ file: AtlasCodeFileChange,
        index: Int,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            whyTarget.wrappedValue = AtlasCodeProvenanceWhyTarget(path: file.path)
        } label: {
            AtlasCodeFileRow(file: file, accessibilityIdentifier: A11yID.whyFileRow(index))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AtlasCodeFileRowA11y.spokenFile(file))
        .accessibilityHint("abre o porquê deste arquivo no commit")
        .accessibilityIdentifier(A11yID.whyFileRow(index))
        .accessibilityAddTraits(.isButton)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func filesSection(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        if !provenance.files.isEmpty {
            filesSectionBody(provenance, whyTarget: whyTarget)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func filesSectionBody(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            filesSectionHeader
            provenanceFilesList(provenance, whyTarget: whyTarget)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var filesSectionHeader: some View {
        Text("ARQUIVOS")
            .atlasSans(8.5, .semibold)
            .tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(A11yID.codeCommitFiles)
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceFilesList(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(provenance.files.enumerated()), id: \.element.id) { index, file in
                if index > 0 {
                    Divider().overlay(AtlasTheme.separator.opacity(0.5))
                }
                provenanceFileButton(file, index: index, whyTarget: whyTarget)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func lawCanonText(_ ruleCanon: String) -> some View {
        Text(ruleCanon)
            .font(AtlasFont.mono(8.5))
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.85))
            .lineLimit(1)
            .truncationMode(.head)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func lawRuleText(_ ruleId: String) -> some View {
        Text(AtlasCodeIssue.law(ruleId, trunk: trunk))
            .font(AtlasFont.serif(14, .semibold))
            .foregroundStyle(AtlasCodePalette.alert)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func lawCitationBody(ruleId: String) -> some View {
        lawCitationChrome(
            VStack(alignment: .leading, spacing: 3) {
                lawRuleText(ruleId)
                if let ruleCanon = ruleCanon?.nonEmpty {
                    lawCanonText(ruleCanon)
                }
            }
        )
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var lawCitationChrome: some View {
        if state == .violating, let ruleId, spokenLawCitation() != nil {
            lawCitationBody(ruleId: ruleId)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func lawCitationChrome<Content: View>(_ content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft)
                    .fill(AtlasCodePalette.alert.opacity(0.08))
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLawCitation() ?? "")
            .accessibilityIdentifier(A11yID.codeProvenanceLaw)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceGatesObra(_ provenance: AtlasCodeProvenance) -> some View {
        if let gates = provenance.gates, !gates.isEmpty {
            block("Prova no ledger") { AtlasCodeChipRow(items: gates) }
        }
        if let obra = provenance.obra, !obra.isEmpty {
            block("Obra") { AtlasCodeChipRow(items: obra) }
        }
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceLoadedBody(_ provenance: AtlasCodeProvenance, whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>) -> some View {
        if hasLoadedBody(provenance) {
            VStack(alignment: .leading, spacing: 18) {
                provenanceProseBlocks(provenance)
                provenanceGatesObra(provenance)
                filesSection(provenance, whyTarget: whyTarget)
            }
        }
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceProseBlocks(_ provenance: AtlasCodeProvenance) -> some View {
        if let body = provenance.commitBody?.nonEmpty {
            Text(AtlasCodeCommitBody.prose(body))
                .font(AtlasFont.serif(15))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier(A11yID.codeCommitBody)
        }

        if let quote = provenance.operatorQuote?.nonEmpty {
            pullQuote(quote)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var pullQuoteBar: some View {
        Rectangle()
            .fill(AtlasTheme.accent.opacity(0.55))
            .frame(width: 2)
    }
}

extension AtlasCodeProvenanceSheet {
    func pullQuoteStack(_ quote: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\u{201C}\(quote)\u{201D}")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text("sua frase")
                .atlasSans(9)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func pullQuote(_ quote: String) -> some View {
        HStack(alignment: .top, spacing: 11) {
            pullQuoteBar
            pullQuoteStack(quote)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityLabel("sua frase: \(quote)")
    }
}


/// M3 · Código — o workspace do operador como ele realmente é.
/// Seções / linhas → AtlasCodeRadarSections / AtlasCodeRadarRows / FolderRow.
struct AtlasCodeRadarView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var model: AtlasCodeWorkspaceModel
    let onOpenRepo: (String) -> Void

    init(client: AtlasClient, onOpenRepo: @escaping (String) -> Void) {
        _model = State(initialValue: AtlasCodeWorkspaceModel(client: client))
        self.onOpenRepo = onOpenRepo
    }

    private var contentPhaseID: String {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        case .failed: return "failed"
        case .loaded:
            guard let workspace = model.workspace else { return "loaded-nil" }
            if workspace.repositoryCount == 0 { return "loaded-empty" }
            return "loaded-\(workspace.repositoryCount)"
        }
    }

    private static let shellHint = "pastas, recentes e sem retorno verificados do seu código"

    var body: some View {
        radarContent
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
            .navigationTitle("Código")
            .navigationBarTitleDisplayMode(.inline)
            .task { if model.phase == .idle { await model.load() } }
            .refreshable { await model.load() }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .accessibilityIdentifier(A11yID.radarScreen)
            // Contain without fused label: folder/repo rows stay focusable.
            .accessibilityElement(children: .contain)
            .accessibilityHint(Self.shellHint)
    }

    @ViewBuilder
    private var radarContent: some View {
        switch model.phase {
        case .idle, .loading:
            TraceEvidenceLoading(text: "lendo o seu workspace…", reduceMotion: reduceMotion)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier(A11yID.radarLoading)
        case .failed(let message):
            AtlasCodeLoadFailureEmpty(
                headline: "não consegui ler o workspace",
                message: message.trimmingCharacters(in: .whitespacesAndNewlines),
                onRetry: { Task { await model.load() } }
            )
            .accessibilityLabel(spokenFailed(message))
            .accessibilityHint("reconecta ao servidor Atlas")
            .accessibilityIdentifier(A11yID.radarFailure)
        case .loaded:
            if let workspace = model.workspace {
                AtlasCodeRadarLoadedContent(
                    workspace: workspace,
                    model: model,
                    onOpenRepo: onOpenRepo
                )
            } else {
                AtlasEditorialGlyphEmpty(
                    headline: "“Workspace sem repositórios legíveis.”",
                    footnote: "o Mac respondeu, mas nenhuma pasta de produto veio nesta leitura",
                    accessibilityIdentifier: A11yID.radarEmpty,
                    spokenLabel: spokenEmptyWorkspace()
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Spoken (phase-local; shell uses contain-without-fuse)

    private func spokenEmptyWorkspace() -> String {
        "nenhum repositório neste workspace"
    }

    private func spokenFailed(_ message: String) -> String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "workspace indisponível" }
        return "workspace indisponível, \(trimmed)"
    }
}


// Cycle 043 fuse → AtlasCodeLoadFailure.swift

/// Falha de carregamento Código — canônico (radar + grafo).
struct AtlasCodeLoadFailureEmpty: View {
    let headline: String
    let message: String
    let onRetry: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .atlasSans(24)
                .foregroundStyle(AtlasCodePalette.alert)
                .accessibilityHidden(true)
            Text(headline)
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(message)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry()
            } label: {
                Text("Tentar de novo")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.accent)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .frame(minHeight: 48)
                    .background(
                        Capsule().fill(AtlasTheme.goldVeil)
                            .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                    )
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("tentar de novo")
            .accessibilityHint("recarrega o grafo ou radar deste repositório")
            .accessibilityIdentifier(A11yID.codeLoadRetry)
            .accessibilityAddTraits(.isButton)
            .accessibilitySortPriority(8)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: 420, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.codeLoadFailure)
    }
}


/// Conteúdo carregado do radar — status, recentes, pastas, avulsos.
struct AtlasCodeRadarLoadedContent: View {
    let workspace: AtlasCodeWorkspaceResponse
    let model: AtlasCodeWorkspaceModel
    let onOpenRepo: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AtlasCodeRadarStatusCapsule(model: model)
                    .padding(.bottom, 18)

                if !workspace.recents.isEmpty {
                    AtlasCodeRadarSectionLabel(text: "RECENTES", accessibilityID: A11yID.radarRecents)
                    ForEach(workspace.recents) { repo in
                        AtlasCodeRepoRow(
                            repo: repo,
                            issues: model.issues(for: repo.slug),
                            trunk: model.trunk(for: repo.slug),
                            showsFolder: true
                        ) {
                            onOpenRepo(repo.slug)
                        }
                        if repo.id != workspace.recents.last?.id { AtlasCodeRadarRowDivider() }
                    }
                }

                if !workspace.folders.isEmpty {
                    AtlasCodeRadarSectionLabel(text: "PASTAS", accessibilityID: A11yID.radarFolders)
                        .padding(.top, 22)
                    ForEach(workspace.folders) { folder in
                        AtlasCodeFolderRow(
                            folder: folder,
                            isExpanded: model.expandedFolders.contains(folder.slug),
                            issuesFor: { model.issues(for: $0) },
                            trunkFor: { model.trunk(for: $0) },
                            onToggle: { Task { await model.toggle(folder) } },
                            onOpenRepo: onOpenRepo
                        )
                        if folder.id != workspace.folders.last?.id { AtlasCodeRadarRowDivider() }
                    }
                }

                if !workspace.loose.isEmpty {
                    AtlasCodeRadarSectionLabel(text: "AVULSOS", accessibilityID: A11yID.radarLoose)
                        .padding(.top, 22)
                    ForEach(workspace.loose) { repo in
                        AtlasCodeRepoRow(
                            repo: repo,
                            issues: model.issues(for: repo.slug),
                            trunk: model.trunk(for: repo.slug),
                            showsFolder: false
                        ) {
                            onOpenRepo(repo.slug)
                        }
                        if repo.id != workspace.loose.last?.id { AtlasCodeRadarRowDivider() }
                    }
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
    }
}


// MARK: - Status capsule + labels do radar

/// Silêncio = produto: clean → caption quieta; alarme só com violação real.
struct AtlasCodeRadarStatusCapsule: View {
    let model: AtlasCodeWorkspaceModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Group {
            switch model.scanState {
            case .clean, .unknown:
                Text(model.scanState == .clean ? "código" : model.headline)
                    .atlasSans(11, .semibold)
                    .tracking(1.2)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.vertical, 7)
                    .accessibilityHidden(true)
            case .violating:
                HStack(spacing: 7) {
                    Image(systemName: "exclamationmark.triangle")
                        .atlasSans(10, .semibold)
                        .accessibilityHidden(true)
                    Text(model.headline)
                        .atlasSans(11, .semibold)
                        .monospacedDigit()
                        .accessibilityHidden(true)
                }
                .foregroundStyle(AtlasCodePalette.alert)
                .padding(.horizontal, 15)
                .padding(.vertical, 7)
                .background(Capsule().fill(AtlasCodePalette.alert.opacity(0.09)))
                .overlay(Capsule().strokeBorder(AtlasCodePalette.alert.opacity(0.35), lineWidth: 1))
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: AtlasMotion.considered), value: model.scanState)
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
        .accessibilityLabel(spokenStatus)
        .accessibilityAddTraits(model.scanState == .violating ? .isHeader : [])
        .accessibilityIdentifier(A11yID.radarStatus)
    }

    /// Frota quieta = caption mínima; alarme só com violação verificada no scan.
    private var spokenStatus: String {
        switch model.scanState {
        case .clean:
            return "código quieto, nada pede você"
        case .unknown:
            return model.headline
        case .violating:
            return "atenção, \(model.headline)"
        }
    }
}

struct AtlasCodeRadarSectionLabel: View {
    let text: String
    var accessibilityID: String? = nil

    var body: some View {
        Text(text)
            .atlasSans(10, .semibold)
            .tracking(1.3)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(accessibilityID ?? text)
    }
}

struct AtlasCodeRadarRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(AtlasTheme.separator.opacity(0.5))
            .frame(height: 0.5)
    }
}


/// Linha de repositório do radar — label visual + spoken honesty.
struct AtlasCodeRepoRow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let repo: AtlasCodeRepoRef
    let issues: [AtlasCodeIssue]?
    /// Trunk real: a frase da issue fala o nome da linha.
    var trunk: String? = nil
    /// Nos recentes a pasta situa; dentro da pasta seria redundante.
    let showsFolder: Bool
    let onTap: () -> Void

    var body: some View {
        // children:.ignore: nó único com label/id — necessário p/ walk a11y estável.
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onTap()
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 7) {
                        Text(repo.name)
                            .atlasSans(15, .medium)
                            .foregroundStyle(AtlasTheme.textPrimary)
                        if showsFolder, let folder = repo.folder {
                            Text(folder)
                                .atlasSans(10)
                                .foregroundStyle(AtlasTheme.textTertiary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1.5)
                                .background(Capsule().fill(AtlasTheme.surface))
                        }
                    }
                    if let issues, let first = issues.first {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(first.isSevere
                                      ? AtlasCodePalette.alert
                                      : AtlasCodePalette.alert.opacity(0.45))
                                .frame(width: 4.5, height: 4.5)
                            Text(
                                issues.count == 1
                                    ? first.headline(trunk: trunk)
                                    : "\(first.headline(trunk: trunk)) · mais \(issues.count - 1) alerta\(issues.count - 1 == 1 ? "" : "s")"
                            )
                            .atlasSans(12)
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .lineLimit(1)
                        }
                    }
                }
                .accessibilityHidden(true)
                Spacer(minLength: 6)
                if let age = AtlasCodeAge.short(from: repo.lastCommitAt) {
                    Text(age)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                        .accessibilityHidden(true)
                }
                Image(systemName: "chevron.right")
                    .atlasSans(12, .semibold)
                    .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 13)
            .frame(minHeight: 48, alignment: .center)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
        .accessibilityHint("abre o grafo do repositório")
        .accessibilityIdentifier(A11yID.radarRepo(repo.slug))
        .accessibilityAddTraits(.isButton)
    }

    /// Desvios só com `issues` publicados; nil = silêncio, nunca fabrica limpo.
    private var spokenLabel: String {
        var parts = [repo.name]
        if showsFolder, let folder = repo.folder, !folder.isEmpty {
            parts.append("pasta \(folder)")
        }
        if let issues, !issues.isEmpty {
            if let first = issues.first {
                parts.append(first.headline(trunk: trunk))
                if first.isSevere { parts.append("alta severidade") }
            }
            if issues.count > 1 {
                let more = issues.count - 1
                parts.append("mais \(more) sem retorno\(more == 1 ? "" : "s")")
            }
        }
        if let age = AtlasCodeAge.short(from: repo.lastCommitAt) {
            parts.append("último commit \(age)")
        }
        return parts.joined(separator: ", ")
    }
}


/// Linha de pasta do radar — expand/collapse + repos + spoken honesty.
struct AtlasCodeFolderRow: View {
    let folder: AtlasCodeFolder
    let isExpanded: Bool
    let issuesFor: (String) -> [AtlasCodeIssue]?
    let trunkFor: (String) -> String?
    let onToggle: () -> Void
    let onOpenRepo: (String) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    /// Só violações de repos já varridos — nil = ainda não medido, nunca conta limpo.
    private var verifiedExceptionCount: Int {
        folder.repos.reduce(0) { total, repo in
            guard let issues = issuesFor(repo.slug), !issues.isEmpty else { return total }
            return total + issues.reduce(0) { $0 + $1.count }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onToggle()
            } label: {
                HStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "folder")
                            .atlasSans(15)
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .frame(width: 20)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(folder.name)
                                .atlasSans(15, .semibold)
                                .foregroundStyle(AtlasTheme.textPrimary)
                            Text(folder.repositories == 1
                                 ? "1 repositório"
                                 : "\(folder.repositories) repositórios")
                                .atlasSans(11.5)
                                .foregroundStyle(AtlasTheme.textTertiary)
                        }
                        .accessibilityHidden(true)
                    }
                    Spacer(minLength: 6)
                    if verifiedExceptionCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle")
                                .atlasSans(9, .semibold)
                            Text("\(verifiedExceptionCount)")
                                .atlasSans(11, .semibold)
                                .monospacedDigit()
                        }
                        .foregroundStyle(AtlasCodePalette.alert)
                        .accessibilityHidden(true)
                    }
                    Image(systemName: "chevron.right")
                        .atlasSans(12, .semibold)
                        .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .accessibilityHidden(true)
                }
                .padding(.vertical, 14)
                .frame(minHeight: 48, alignment: .center)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenFolderLabel)
            .accessibilityHint(isExpanded ? "recolhe a pasta" : "expande a pasta")
            .accessibilityAddTraits(isExpanded ? [.isButton, .isSelected] : .isButton)
            .accessibilityIdentifier(A11yID.radarFolder(folder.slug))

            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(folder.repos) { repo in
                        AtlasCodeRepoRow(
                            repo: repo,
                            issues: issuesFor(repo.slug),
                            trunk: trunkFor(repo.slug),
                            showsFolder: false
                        ) {
                            onOpenRepo(repo.slug)
                        }
                        .padding(.leading, 32)
                        if repo.id != folder.repos.last?.id {
                            Rectangle()
                                .fill(AtlasTheme.separator.opacity(0.4))
                                .frame(height: 0.5)
                                .padding(.leading, 32)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .padding(.bottom, 6)
                .transition(reduceMotion ? .identity : .opacity)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: AtlasMotion.instinct), value: isExpanded)
    }

    private var spokenFolderLabel: String {
        var parts = [
            folder.name,
            folder.repositories == 1 ? "1 repositório" : "\(folder.repositories) repositórios"
        ]
        if verifiedExceptionCount > 0 {
            let n = verifiedExceptionCount
            parts.append("\(n) sem retorno\(n == 1 ? "" : "s") verificado\(n == 1 ? "" : "s")")
        }
        if isExpanded { parts.append("expandida") }
        return parts.joined(separator: ", ")
    }
}


// Cycle 044 fuse → AtlasCodeCommitRow.swift

// MARK: - Linha do commit (mensagem é a manchete)

struct AtlasCodeCommitRow: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let node: AtlasCodeGraphNode
    let state: AtlasCodeNodeState
    let ruleId: String?
    /// A trunk real: a lei na linha fala o nome da linha, nunca "main" no chute.
    let trunk: String?
    let isFirst: Bool
    let isLast: Bool
    /// Estado do vizinho acima/abaixo no filtro atual — continuidade da lane.
    var aboveState: AtlasCodeNodeState? = nil
    var belowState: AtlasCodeNodeState? = nil
    /// A pílula respondeu e este commit não está na resposta: ele recua, mas
    /// nunca some — esconder história para responder uma pergunta seria mentir
    /// sobre o repositório.
    var isDimmed: Bool = false
    let onTap: () -> Void
    var onLongPress: (() -> Void)? = nil
    var onAsk: (() -> Void)? = nil

    var color: Color { AtlasCodePalette.color(for: state) }

    var body: some View {
        commitRowA11yChrome
    }

    // MARK: Label + text

    var commitRowLabel: some View {
        HStack(alignment: .top, spacing: 12) {
            spine
            commitRowTextStack
            Spacer(minLength: 0)
        }
        .padding(.vertical, 7)
        .contentShape(Rectangle())
    }

    var commitRowTextStack: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titleText)
                .atlasSans(14, .medium)
                .foregroundStyle(state == .violating ? color : AtlasTheme.textPrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .accessibilityHidden(true)
            commitMetaLine
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, isFirst ? 4 : 0)
        .padding(.horizontal, isFirst ? 8 : 0)
        .background {
            if isFirst {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AtlasTheme.accent.opacity(0.07), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
    }

    // MARK: Meta (branch · autor · tempo · lei)

    var commitMetaLine: some View {
        HStack(spacing: 6) {
            commitMetaAuthorTime
            if let ruleId {
                Text("·")
                    .accessibilityHidden(true)
                Text(AtlasCodeIssue.law(ruleId, trunk: trunk))
                    .foregroundStyle(color)
                    .accessibilityHidden(true)
            }
        }
        .font(AtlasFont.mono(9))
        .foregroundStyle(AtlasTheme.textTertiary)
    }

    @ViewBuilder
    var commitMetaAuthorTime: some View {
        Text(displayBranch)
            .foregroundStyle(branchMetaColor)
            .accessibilityHidden(true)
        Text("·")
            .accessibilityHidden(true)
        Text(displayAuthor)
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityHidden(true)
        Text("·")
            .accessibilityHidden(true)
        Text(AtlasCodeRelativeTime.short(from: node.authoredAt))
            .accessibilityHidden(true)
    }

    private var branchMetaColor: Color {
        switch state {
        case .violating: return AtlasCodePalette.alert
        case .onMain, .healed: return AtlasTheme.accent
        case .history: return AtlasTheme.prussian
        }
    }

    /// Nome de branch publicado no tip, se o git decorou este nó.
    static func tipBranch(from refs: [String], excluding: String?) -> String? {
        for ref in refs {
            let name = ref
                .replacingOccurrences(of: "HEAD -> ", with: "")
                .replacingOccurrences(of: "origin/", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if name.isEmpty || name == "HEAD" { continue }
            if let excluding, name == excluding { continue }
            return name
        }
        return nil
    }

    var displayBranch: String {
        if let tip = Self.tipBranch(from: node.refs, excluding: trunk) {
            return tip
        }
        if let tip = Self.tipBranch(from: node.refs, excluding: nil) {
            return tip
        }
        if state == .onMain || state == .healed {
            return trunk ?? "main"
        }
        return trunk ?? "—"
    }

    var displayAuthor: String {
        if !node.authorName.isEmpty { return node.authorName }
        if !node.authorEmail.isEmpty { return node.authorEmail }
        return "—"
    }

    var titleText: String {
        guard let message = node.message, !message.isEmpty else {
            return String(node.hash.prefix(8))
        }
        return message
    }

    var commitAccessibilityHint: String {
        guard !isDimmed else { return "" }
        if onAsk != nil {
            return "abre proveniência; arraste para a esquerda para usar na pílula"
        }
        if onLongPress != nil { return "abre proveniência do commit; pressione e segure para opções" }
        return "abre proveniência do commit"
    }

    func commitLongPress() {
        onLongPress?()
    }

    // MARK: A11y chrome (tap · long press · swipe ask)

    var commitRowA11yChrome: some View {
        CommitRowAskChrome(
            isDimmed: isDimmed,
            reduceMotion: reduceMotion,
            label: { commitRowLabel },
            accessibilityLabel: AtlasCodeCommitRowA11y.spokenCommitRow(
                node: node, state: state, trunk: trunk, ruleId: ruleId, isDimmed: isDimmed
            ),
            accessibilityHint: commitAccessibilityHint,
            accessibilityID: A11yID.codeCommit(hashPrefix: String(node.hash.prefix(8))),
            onTap: onTap,
            onLongPress: commitLongPress,
            onAsk: onAsk
        )
    }
}

private struct CommitRowAskChrome<Label: View>: View {
    let isDimmed: Bool
    let reduceMotion: Bool
    @ViewBuilder let label: () -> Label
    let accessibilityLabel: String
    let accessibilityHint: String
    let accessibilityID: String
    let onTap: () -> Void
    let onLongPress: () -> Void
    let onAsk: (() -> Void)?

    @State private var offset: CGFloat = 0
    /// Evita que o fim do swipe dispare o Button (proveniência).
    @State private var suppressTap = false

    var body: some View {
        Button {
            guard !suppressTap else { return }
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onTap()
        } label: {
            label()
        }
        .buttonStyle(.plain)
        .offset(x: offset)
        .opacity(isDimmed ? 0.26 : 1)
        .animation(reduceMotion ? nil : .easeInOut(duration: AtlasMotion.considered), value: isDimmed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityIdentifier(accessibilityID)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: "Opções do commit") { onLongPress() }
        .modifier(CommitRowAskA11yAction(onAsk: onAsk))
        .onLongPressGesture(minimumDuration: 0.45, perform: onLongPress)
        .simultaneousGesture(askDrag)
    }

    private var askDrag: some Gesture {
        DragGesture(minimumDistance: 28)
            .onChanged { value in
                guard onAsk != nil else { return }
                let dx = value.translation.width
                let dy = value.translation.height
                guard abs(dx) > abs(dy), dx < 0 else { return }
                offset = max(dx, -72)
            }
            .onEnded { value in
                guard onAsk != nil else {
                    offset = 0
                    return
                }
                let shouldAsk = value.translation.width < -56
                let reset = { offset = 0 }
                if reduceMotion {
                    reset()
                } else {
                    withAnimation(.easeOut(duration: AtlasMotion.instinct), reset)
                }
                guard shouldAsk else { return }
                suppressTap = true
                onAsk?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    suppressTap = false
                }
            }
    }
}

/// VoiceOver secondary: swipe-to-ask when the row exposes onAsk.
private struct CommitRowAskA11yAction: ViewModifier {
    let onAsk: (() -> Void)?

    func body(content: Content) -> some View {
        if let onAsk {
            content.accessibilityAction(named: "Perguntar na pílula") { onAsk() }
        } else {
            content
        }
    }
}

/// Spoken labels da linha de commit.
/// Trunk/lei só quando publicados; tempo relativo honesto; dimmed explícito.

enum AtlasCodeCommitRowA11y {
    static func spokenCommitRow(
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        trunk: String?,
        ruleId: String?,
        isDimmed: Bool
    ) -> String {
        let identity = AtlasCodeCommitRowA11yRowIdentity.parts(node: node, trunk: trunk)
        var parts = AtlasCodeCommitRowA11yState.stateParts(
            title: identity.title,
            author: identity.author,
            linha: identity.linha,
            state: state,
            ruleId: ruleId,
            trunk: trunk
        )
        parts.append(contentsOf: spokenCommitTail(authoredAt: node.authoredAt, isDimmed: isDimmed))
        return parts.joined(separator: ", ")
    }

    static func spokenCommitTail(authoredAt: Int, isDimmed: Bool) -> [String] {
        var parts: [String] = []
        let when = AtlasCodeRelativeTime.short(from: authoredAt)
        if !when.isEmpty { parts.append("há \(when)") }
        if isDimmed { parts.append("fora da resposta") }
        return parts
    }
}

enum AtlasCodeCommitRowA11yRowIdentity {
    static func parts(
        node: AtlasCodeGraphNode,
        trunk: String?
    ) -> (title: String, author: String, linha: String) {
        // VoiceOver lidera pelo TIPO (só a palavra, sem escopo — fala limpa) e
        let title: String
        if let message = node.message {
            let parsed = AtlasConventionalCommit.split(message)
            let typeWord = parsed.type.map { String($0.prefix { $0.isLetter }) }
            title = typeWord.map { "\($0), \(parsed.subject)" } ?? parsed.subject
        } else {
            title = String(node.hash.prefix(8))
        }
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        let linha = trunk?.nonEmpty ?? "linha principal"
        return (title, author, linha)
    }
}

enum AtlasCodeCommitRowA11yState {
    static func stateParts(
        title: String,
        author: String,
        linha: String,
        state: AtlasCodeNodeState,
        ruleId: String?,
        trunk: String?
    ) -> [String] {
        switch state {
        case .violating:
            return violatingParts(
                title: title,
                author: author,
                linha: linha,
                ruleId: ruleId,
                trunk: trunk
            )
        default:
            return branchParts(title: title, author: author, linha: linha, state: state)
        }
    }

    static func violatingParts(
        title: String,
        author: String,
        linha: String,
        ruleId: String?,
        trunk: String?
    ) -> [String] {
        var parts = [title, "por \(author)", "fora da \(linha)"]
        if let ruleId { parts.append(AtlasCodeIssue.law(ruleId, trunk: trunk)) }
        return parts
    }

    static func branchParts(
        title: String,
        author: String,
        linha: String,
        state: AtlasCodeNodeState
    ) -> [String] {
        if let healthy = branchPartsHealthy(title: title, author: author, linha: linha, state: state) {
            return healthy
        }
        switch state {
        case .history:
            return historyParts(title: title, author: author)
        case .violating:
            return []
        default:
            return []
        }
    }

    static func branchPartsHealthy(
        title: String,
        author: String,
        linha: String,
        state: AtlasCodeNodeState
    ) -> [String]? {
        switch state {
        case .healed:
            return healedParts(title: title, author: author)
        case .onMain:
            return onMainParts(title: title, author: author, linha: linha)
        default:
            return nil
        }
    }

    static func healedParts(title: String, author: String) -> [String] {
        [title, "por \(author)", "curado"]
    }

    static func onMainParts(title: String, author: String, linha: String) -> [String] {
        [title, "por \(author)", "na \(linha)"]
    }

    static func historyParts(title: String, author: String) -> [String] {
        [title, "por \(author)", "história"]
    }
}

// Espinha do grafo: coluna, conectores, nó, ✦/disco.
// Decorativa: spoken vive em AtlasCodeCommitRow+A11y.

extension AtlasCodeCommitRow {
    /// Linha contínua + nó. Cor via `AtlasCodePalette` (contrato); sem spoken.
    @ViewBuilder
    var spine: some View {
        let spineTint = color.opacity(0.45)
        let motion = AtlasMotionPresentation.editorial(reduceMotion: reduceMotion)
        spineColumn(spineTint: spineTint, motion: motion)
    }

    @ViewBuilder
    func spineColumn(spineTint: Color, motion: Animation?) -> some View {
        spineColumnFrame(
            spineColumnConnectors(spineTint: spineTint, motion: motion),
            motion: motion
        )
    }

    @ViewBuilder
    func spineColumnFrame<Content: View>(_ content: Content, motion: Animation?) -> some View {
        content
            .frame(width: AtlasCodeGraphLane.gutter)
            .frame(minHeight: 44)
            .animation(motion, value: state)
            .animation(motion, value: isFirst)
            .animation(motion, value: isLast)
            .atlasCodeGraphSpineDecorative()
    }

    /// Newest-first: tip acima, origem abaixo. Zero C flutuante, zero faixa cinza extra.
    @ViewBuilder
    func spineColumnConnectors(spineTint: Color, motion: Animation?) -> some View {
        let lane = AtlasCodeGraphLane.index(for: state)
        let above = AtlasCodeGraphLane.index(for: aboveState ?? .onMain)
        let below = AtlasCodeGraphLane.index(for: belowState ?? .onMain)
        let trunkX = AtlasCodeGraphLane.base
        let sideX = AtlasCodeGraphLane.sideX
        let laneX = AtlasCodeGraphLane.x(lane: lane)
        let nodeY = AtlasCodeGraphLane.nodeCenterY

        ZStack(alignment: .topLeading) {
            Canvas { context, size in
                let h = max(size.height, nodeY + 12)
                strokeTrunk(context: context, trunkX: trunkX, nodeY: nodeY, h: h)

                // Origem: este ✦ é o pai — faixa está ACIMA (tip/cadeia mais nova).
                if lane == 0, above > 0, !isFirst {
                    let peel = AtlasCodeGraphLane.forkPath(
                        from: CGPoint(x: trunkX, y: nodeY),
                        to: CGPoint(x: sideX, y: 0)
                    )
                    context.stroke(
                        peel,
                        with: .color(peelColorTowardAbove.opacity(0.92)),
                        lineWidth: AtlasCodeGraphLane.sideWidth
                    )
                }

                guard lane > 0 else { return }

                let stroke = sideStrokeColor

                // Chega de cima (cadeia na mesma faixa).
                if above > 0, !isFirst {
                    var up = Path()
                    up.move(to: CGPoint(x: sideX, y: 0))
                    up.addLine(to: CGPoint(x: sideX, y: nodeY))
                    context.stroke(up, with: .color(stroke), lineWidth: AtlasCodeGraphLane.sideWidth)
                }

                if below == 0, !isLast {
                    var fromParent = Path()
                    fromParent.move(to: CGPoint(x: sideX, y: h))
                    fromParent.addLine(to: CGPoint(x: sideX, y: nodeY))
                    context.stroke(fromParent, with: .color(stroke), lineWidth: AtlasCodeGraphLane.sideWidth)
                } else if below > 0, !isLast {
                    var down = Path()
                    down.move(to: CGPoint(x: sideX, y: nodeY))
                    down.addLine(to: CGPoint(x: sideX, y: h))
                    context.stroke(down, with: .color(stroke), lineWidth: AtlasCodeGraphLane.sideWidth)
                } else if isLast {
                    // Sem pai na lista: elbow no próprio tip (única âncora possível).
                    let elbow = AtlasCodeGraphLane.forkPath(
                        from: CGPoint(x: trunkX, y: nodeY),
                        to: CGPoint(x: sideX, y: nodeY)
                    )
                    context.stroke(elbow, with: .color(stroke), lineWidth: AtlasCodeGraphLane.sideWidth)
                }
            }
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                Color.clear.frame(height: max(0, nodeY - 11))
                HStack(spacing: 0) {
                    Color.clear.frame(width: max(0, laneX - 11))
                    spineNode(motion: motion)
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func strokeTrunk(
        context: GraphicsContext,
        trunkX: CGFloat,
        nodeY: CGFloat,
        h: CGFloat
    ) {
        var trunk = Path()
        let top: CGFloat = isFirst ? nodeY : 0
        let bot: CGFloat = isLast ? nodeY : h
        guard bot > top else { return }
        trunk.move(to: CGPoint(x: trunkX, y: top))
        trunk.addLine(to: CGPoint(x: trunkX, y: bot))
        context.stroke(
            trunk,
            with: .color(AtlasTheme.accent.opacity(0.42)),
            lineWidth: AtlasCodeGraphLane.trunkWidth
        )
    }

    private var sideStrokeColor: Color {
        color.opacity(state == .history ? 0.5 : 0.92)
    }

    private var peelColorTowardAbove: Color {
        guard let aboveState else { return AtlasCodePalette.alert }
        return AtlasCodePalette.color(for: aboveState)
    }

    @ViewBuilder
    func spineNode(motion: Animation?) -> some View {
        ZStack {
            spineViolatingRing(motion: motion)
            spineCoreDot
        }
        .frame(width: 22, height: 22)
        .animation(motion, value: state == .violating)
    }

    /// Trunk/healed = ✦ Atlas. Fora/obra = disco na lane (canon r≈5.5).
    @ViewBuilder
    var spineCoreDot: some View {
        switch state {
        case .onMain, .healed:
            Text("✦")
                .font(AtlasFont.serif(state == .onMain && !isFirst ? 11 : 13))
                .foregroundStyle(color)
                .shadow(color: color.opacity(isFirst ? 0.45 : 0.25), radius: isFirst ? 5 : 3, y: 0)
                .accessibilityHidden(true)
        case .violating, .history:
            let d = AtlasCodeGraphLane.nodeRadius * 2
            Circle()
                .fill(color)
                .frame(width: d, height: d)
                .overlay(
                    Circle()
                        .strokeBorder(AtlasTheme.bg, lineWidth: 2)
                        .frame(width: d + 3, height: d + 3)
                )
                .accessibilityHidden(true)
        }
    }

    /// Violating ring — morto. Exceção = geometria de lane + disco, não anel no tronco.
    @ViewBuilder
    func spineViolatingRing(motion: Animation?) -> some View {
        EmptyView()
    }
}

extension View {
    /// Silencia conectores e nó; VoiceOver só ouve a linha do commit.
    func atlasCodeGraphSpineDecorative() -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityHidden(true)
    }
}


/// Divide um assunto de commit convencional "tipo(escopo): frase" em
/// (tipo, frase). Presentation-only — só separa quando o prefixo é MESMO um
/// tipo convencional conhecido; mensagem comum fica inteira, tipo nil.
/// Ausência de tipo nunca vira tipo inventado (lei da honestidade).
enum AtlasConventionalCommit {
    // ponytail: whitelist de tipos — evita falso-positivo de mensagem comum
    // com ":" ("nota: isso"). Cobre os tipos usados no Atlas + os padrão.
    private static let knownTypes: Set<String> = [
        "feat", "fix", "docs", "polish", "refactor", "chore",
        "test", "style", "perf", "build", "ci", "revert", "wip"
    ]

    /// `type` normalizado: minúsculo, PRIMEIRO segmento com escopo
    /// ("fix(ui)+polish(ui)" → "fix(ui)"); nil quando não-convencional.
    static func split(_ message: String) -> (type: String?, subject: String) {
        guard let sep = message.range(of: ": ") else { return (nil, message) }
        let head = String(message[..<sep.lowerBound])
        let subject = String(message[sep.upperBound...]).trimmingCharacters(in: .whitespaces)
        guard !subject.isEmpty, let type = conventionalType(head) else { return (nil, message) }
        return (type, subject)
    }

    private static func conventionalType(_ head: String) -> String? {
        guard !head.isEmpty, head.count <= 40, !head.contains(" ") else { return nil }
        // Primeiro segmento (antes de '+'): o tipo primário do commit.
        let segment = head.split(separator: "+", maxSplits: 1).first.map(String.init) ?? head
        let typeWord = segment.prefix { $0.isLetter }
        let remainder = segment[typeWord.endIndex...]
        // O resto do segmento tem de ser escopo/marca VÁLIDA ("(...)", "!" ou
        // vazio) — senão "fix-me"/"ci-cd" viraria tipo (falso-positivo).
        guard knownTypes.contains(typeWord.lowercased()), isValidScope(remainder) else { return nil }
        return typeWord.lowercased() + remainder
    }

    private static func isValidScope(_ raw: Substring) -> Bool {
        var s = raw
        if s.hasSuffix("!") { s = s.dropLast() }
        if s.isEmpty { return true }
        return s.first == "(" && s.last == ")"
    }
}


// Lanes do grafo — presentation-only.
// Uma faixa de exceção (fora + história): sabe-se DE ONDE saiu (peel no ✦ pai).
// Grid: trunk=24, side=24+36. Curva = midpoint (tangente vertical).

enum AtlasCodeGraphLane {
    static let gutter: CGFloat = 72
    static let base: CGFloat = 24
    static let step: CGFloat = 36
    static let trunkWidth: CGFloat = 2.2
    static let sideWidth: CGFloat = 1.85
    static let nodeRadius: CGFloat = 5.5
    static let nodeCenterY: CGFloat = 22

    /// 0 = trunk. 1 = exceção (violating + history na MESMA faixa — sem linha cinza solta).
    static func index(for state: AtlasCodeNodeState) -> Int {
        switch state {
        case .onMain, .healed: return 0
        case .violating, .history: return 1
        }
    }

    static func x(for state: AtlasCodeNodeState) -> CGFloat {
        base + CGFloat(index(for: state)) * step
    }

    static func x(lane: Int) -> CGFloat {
        base + CGFloat(max(0, lane)) * step
    }

    static var sideX: CGFloat { x(lane: 1) }

    /// Curva GitKraken: tangentes verticais no midpoint Y.
    static func forkPath(from: CGPoint, to: CGPoint) -> Path {
        Path { path in
            let midY = (from.y + to.y) / 2
            path.move(to: from)
            path.addCurve(
                to: to,
                control1: CGPoint(x: from.x, y: midY),
                control2: CGPoint(x: to.x, y: midY)
            )
        }
    }
}


// Cycle 044 fuse → AtlasCodePalette.swift

// MARK: - Paleta do domínio (gramática de estado)

enum AtlasCodePalette {
    static let onMain = AtlasTheme.accent
    static let alert = Color(hex: 0xE08C8C)
    static let healed = Color(hex: 0x83B46D)
    static let history = Color(hex: 0x647682)
}

extension AtlasCodePalette {
    static func colorHealthy(for state: AtlasCodeNodeState) -> Color? {
        switch state {
        case .onMain: return onMain
        case .healed: return healed
        default: return nil
        }
    }
}

extension AtlasCodePalette {
    static func color(for state: AtlasCodeNodeState) -> Color {
        if let healthy = colorHealthy(for: state) { return healthy }
        switch state {
        case .violating: return alert
        case .history: return history
        default: return history
        }
    }
}

enum AtlasCodeRelativeTime {
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

struct AtlasCodeChipRow: View {
    let items: [String]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasCodePalette.healed)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .frame(minHeight: 28)
                    .overlay(
                        Capsule().strokeBorder(AtlasCodePalette.healed.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(items.joined(separator: ", "))
    }
}


@MainActor
@Observable
final class AtlasCodeModel {

    let client: AtlasClient
    private(set) var repo: String
    private(set) var phase: LoadPhase = .idle
    private(set) var graph: AtlasCodeGraphResponse?
    private(set) var violations: AtlasCodeViolationsResponse?
    private(set) var heal: AtlasCodeHealResponse?
    private(set) var week: AtlasCodeWeek?

    init(client: AtlasClient, repo: String = "atlas-server") {
        self.client = client
        self.repo = repo
    }

    /// Troca in-place — a casca não remonta a NavigationStack.
    func adoptRepo(_ newRepo: String) {
        guard newRepo != repo else { return }
        repo = newRepo
        phase = .idle
        graph = nil
        violations = nil
        heal = nil
        week = nil
        spineHashes = []
        undoError = nil
    }

    func load(before: String? = nil) async {
        let requested = repo
        phase = .loading
        do {
            // Grafo primeiro: a tela ganha mapa sem esperar heal/week/scan.
            let graph = try await client.getCodeGraph(repo: requested, before: before)
            guard repo == requested else { return }
            self.graph = graph
            spineHashes = AtlasCodeGraphState.spine(nodes: graph.nodes, head: graph.trunkHead)
            phase = .loaded

            async let violationsTask = client.getCodeViolations(repo: requested)
            async let healTask = client.getCodeHealTick(repo: requested)
            async let weekTask = client.getCodeWeek(repo: requested)
            let nextViolations = try? await violationsTask
            let nextHeal = try? await healTask
            let nextWeek = try? await weekTask
            guard repo == requested else { return }
            violations = nextViolations
            heal = nextHeal
            week = nextWeek
            AtlasNativeSnapshotWriter.shared.recordCodeWeek(week)
        } catch {
            guard repo == requested else { return }
            phase = .failed(String(describing: error))
        }
    }

    func undoLastHeal() async {
        guard let id = heal?.healId else { return }
        do {
            _ = try await client.undoCodeHeal(id: id, repo: repo)
            heal = try? await client.getCodeHealTick(repo: repo)
            // O veto muda o mundo: o mapa tem de contar a verdade nova.
            graph = try? await client.getCodeGraph(repo: repo)
            violations = try? await client.getCodeViolations(repo: repo)
        } catch {
            // O veto FALHOU (rede, 500) — e apagar o recibo aqui era esconder
            // exatamente o que o operador tentava desfazer: a folha sumia, ele
            // ficava sem saber se o undo pegou nem como tentar de novo. Falha de
            // veto mantém o recibo na tela; a cura ainda está lá para ser
            // vetada. Silêncio de falha não pode apagar a única ação humana
            // desta tela.
            undoError = "não consegui desfazer agora — a cura continua aqui, tente de novo."
        }
    }

    /// Última falha do veto, para a folha do recibo dizer que o undo não pegou.
    /// `nil` = sem erro pendente; a folha não inventa alarme.
    private(set) var undoError: String?

    /// A espinha inteira, calculada UMA vez por grafo — não uma travessia por
    /// nó, que seria O(n²) numa lista que rola.
    var spineHashes: Set<String> = []
}


// Gramática de estado do grafo — peel de AtlasCodeModel (régua ~160).

extension AtlasCodeModel {
    // MARK: - Gramática de estado (cor = estado, nunca autor)

    /// Casa o alvo da violação (uma ref ou um hash) com os nós reais. Sem
    /// correspondência, nenhum nó acende — ausência nunca vira suspeita.
    func matches(_ node: AtlasCodeGraphNode, target rawTarget: String) -> Bool {
        let target = rawTarget.trimmingCharacters(in: .whitespaces)
        guard !target.isEmpty else { return false }
        if node.hash == target || node.hash.hasPrefix(target) { return true }
        return node.refs.contains { ref in
            ref.replacingOccurrences(of: "HEAD -> ", with: "")
                .replacingOccurrences(of: "origin/", with: "")
                .trimmingCharacters(in: .whitespaces) == target
        }
    }

    var violatingHashes: Set<String> {
        guard let violations, let graph else { return [] }
        var hashes: Set<String> = []
        for violation in violations.violations {
            for node in graph.nodes where matches(node, target: violation.target) {
                hashes.insert(node.hash)
            }
        }
        return hashes
    }

    /// Hashes que o Atlas curou sozinho — o recibo é a fonte, não a UI.
    var healedHashes: Set<String> {
        guard let heal else { return [] }
        var hashes: Set<String> = []
        for receipt in heal.stepReceipts where receipt.status == "completed" {
            if let head = receipt.undoRef?["head"], !head.isEmpty {
                hashes.insert(head)
            }
        }
        return hashes
    }

    func state(for node: AtlasCodeGraphNode) -> AtlasCodeNodeState {
        AtlasCodeGraphState.state(
            for: node,
            defaultBranch: graph?.defaultBranch,
            violatingHashes: violatingHashes,
            healedHashes: healedHashes,
            spineHashes: spineHashes
        )
    }

    /// A regra citada pelo nome — sinal primário, jamais erro genérico.
    func ruleId(for node: AtlasCodeGraphNode) -> String? {
        violations?.violations.first { matches(node, target: $0.target) }?.ruleId
    }

    /// O documento canônico que sustenta a acusação contra este nó.
    func ruleCanon(for node: AtlasCodeGraphNode) -> String? {
        violations?.violations.first { matches(node, target: $0.target) }?.ruleCanonRef
    }

    var hasViolations: Bool { !(violations?.violations.isEmpty ?? true) }

    var hasHealReceipt: Bool { !(heal?.stepReceipts.isEmpty ?? true) }

    /// Estado por exceção: quando o mundo está são, a tela diz isso e cala.
    /// Vocabulário canônico do operador: **sem retorno** (não “desvios”).
    var statusHeadline: String {
        let linha = violations?.trunk
        guard let violations else {
            return linha.map { "não consegui varrer a \($0)" } ?? "não consegui varrer a linha principal"
        }
        if violations.violations.count > 0 {
            let quantos = violations.violations.count
            // Unidade = contagem do scan (mesma da casca); §5 reconcilia obra/branch no Core.
            return quantos == 1 ? "1 sem retorno" : "\(quantos) sem retorno"
        }
        let integra = linha.map { "\($0) íntegra" } ?? "linha principal íntegra"
        if hasHealReceipt { return "\(integra) · curada sem você" }
        return integra
    }

    /// O estado geral que a cápsula pinta — TRÊS, não dois.
    var scanState: AtlasCodeScanState {
        guard let violations else { return .unknown }
        return violations.violations.isEmpty ? .clean : .violating
    }
}


/// M3 · Modelo do workspace do radar de Código.
///
/// Modelo mental correto: `Atlas/` e `blackink/` são PASTAS de produto que
/// contêm repositórios; pasta não é repositório quebrado. A tela mostra
/// **Recentes** (o trabalho vivo — atalho, não cópia) e **Pastas** (a verdade
/// completa). Scan/headline: AtlasCodeWorkspaceModel+Scan.swift
@MainActor
@Observable
final class AtlasCodeWorkspaceModel {

    let client: AtlasClient
    private(set) var phase: LoadPhase = .idle
    private(set) var workspace: AtlasCodeWorkspaceResponse?
    var issuesBySlug: [String: [AtlasCodeIssue]] = [:]
    var trunkBySlug: [String: String] = [:]
    var failedSlugs: Set<String> = []
    var expandedFolders: Set<String> = []

    init(client: AtlasClient) {
        self.client = client
    }

    /// Hidrata na hora a partir do cache — picker sem frame de loading.
    func seedFromCache() {
        guard let cached = AtlasCodeWorkspaceCache.peek() else { return }
        workspace = cached
        phase = .loaded
    }

    func load() async {
        phase = .loading
        do {
            let response = try await client.getCodeWorkspace()
            AtlasCodeWorkspaceCache.store(response)
            workspace = response
            phase = .loaded
            await scan(response.recents.map(\.slug))
        } catch {
            phase = .failed(String(describing: error))
        }
    }

    /// Só a frota (pastas/repos) — sem scan de violações.
    /// Cache quente → instantâneo no picker do grafo.
    func loadStructure() async {
        if let cached = AtlasCodeWorkspaceCache.peek() {
            workspace = cached
            phase = .loaded
            return
        }
        phase = .loading
        do {
            let response = try await client.getCodeWorkspace()
            AtlasCodeWorkspaceCache.store(response)
            workspace = response
            phase = .loaded
        } catch {
            phase = .failed(String(describing: error))
        }
    }

    func toggle(_ folder: AtlasCodeFolder) async {
        if expandedFolders.contains(folder.slug) {
            expandedFolders.remove(folder.slug)
        } else {
            expandedFolders.insert(folder.slug)
            await scan(folder.repos.map(\.slug))
        }
    }

    func issues(for slug: String) -> [AtlasCodeIssue]? { issuesBySlug[slug] }

    func trunk(for slug: String) -> String? { trunkBySlug[slug] }
}

// Cache da frota — o picker não espera a rede se o radar/grafo já leu.
@MainActor
enum AtlasCodeWorkspaceCache {
    private static var structure: AtlasCodeWorkspaceResponse?
    private static var fetchedAt: Date?
    /// 90s: troca de repo no mesmo minuto não paga getCodeWorkspace de novo.
    private static let ttl: TimeInterval = 90

    static func peek() -> AtlasCodeWorkspaceResponse? {
        guard let structure, let fetchedAt,
              Date().timeIntervalSince(fetchedAt) < ttl else { return nil }
        return structure
    }

    static func store(_ response: AtlasCodeWorkspaceResponse) {
        structure = response
        fetchedAt = Date()
    }
}


extension AtlasCodeWorkspaceModel {
    /// Varredura sob demanda: repo que não responde não ganha sinal — jamais
    /// vira "0 problemas".
    func scan(_ slugs: [String]) async {
        for slug in slugs where issuesBySlug[slug] == nil {
            guard let response = try? await client.getCodeViolations(repo: slug) else {
                failedSlugs.insert(slug)
                continue
            }
            failedSlugs.remove(slug)
            issuesBySlug[slug] = Self.group(response.violations)
            if let trunk = response.trunk { trunkBySlug[slug] = trunk }
        }
    }

    /// A frase do workspace: o problema dominante entre o que já foi varrido.
    var headline: String {
        let all = issuesBySlug.values.flatMap { $0 }
        guard !all.isEmpty else {
            if !failedSlugs.isEmpty {
                let mudos = failedSlugs.count
                return mudos == 1 ? "1 repositório não respondeu" : "\(mudos) repositórios não responderam"
            }
            return issuesBySlug.isEmpty ? "lendo o workspace…" : "nada pede você"
        }
        var byRule: [String: AtlasCodeIssue] = [:]
        for issue in all {
            if let existing = byRule[issue.ruleId] {
                byRule[issue.ruleId] = AtlasCodeIssue(
                    ruleId: issue.ruleId,
                    count: existing.count + issue.count,
                    severity: existing.isSevere || issue.isSevere ? "high" : issue.severity,
                    oldestDays: [existing.oldestDays, issue.oldestDays].compactMap { $0 }.max()
                )
            } else {
                byRule[issue.ruleId] = issue
            }
        }
        let worst = byRule.values.sorted { ($0.isSevere ? 0 : 1, -$0.count) < ($1.isSevere ? 0 : 1, -$1.count) }
        return worst.first?.headline ?? "nada pede você"
    }

    var hasException: Bool { issuesBySlug.values.contains { !$0.isEmpty } }

    var scanState: AtlasCodeScanState {
        if hasException { return .violating }
        if !failedSlugs.isEmpty || issuesBySlug.isEmpty { return .unknown }
        return .clean
    }

    static func group(_ violations: [AtlasCodeViolation], now: Date = Date()) -> [AtlasCodeIssue] {
        var byRule: [String: (count: Int, severe: Bool, oldest: Int?)] = [:]
        for violation in violations {
            var entry = byRule[violation.ruleId] ?? (0, false, nil)
            entry.count += 1
            entry.severe = entry.severe || violation.severity == "high"
            if let since = violation.since, let date = AtlasCodeISO.date(from: since) {
                let days = max(0, Int(now.timeIntervalSince(date) / 86_400))
                entry.oldest = max(entry.oldest ?? 0, days)
            }
            byRule[violation.ruleId] = entry
        }
        return byRule
            .map { AtlasCodeIssue(ruleId: $0.key, count: $0.value.count, severity: $0.value.severe ? "high" : "medium", oldestDays: $0.value.oldest) }
            .sorted { ($0.isSevere ? 0 : 1, -$0.count) < ($1.isSevere ? 0 : 1, -$1.count) }
    }
}

enum AtlasCodeISO {
    /// Delega ao parse canônico do Core (gotcha de segundos fracionários).
    static func date(from text: String) -> Date? {
        AtlasTime.date(text)
    }
}

