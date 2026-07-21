import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: AtlasCodeSurface + AtlasCodeView entry fused

// MARK: - Surface

// MARK: - Host

extension AtlasCodeView {
    /// WAVE-061: exclusive graph-screen face from published phase + nodes.
// MARK: - Screen face / spoken
    var graphScreenFace: AtlasCodeGraphScreenFace {
        let fail: String? = {
            if case .failed(let message) = model.phase { return message }
            return nil
        }()
        return AtlasCodeGraphLoadJudgment.face(
            phase: model.phase,
            nodeCount: model.graph?.nodes.count ?? 0,
            failMessage: fail
        )
    }

    func spokenCodeScreenLabel() -> String {
        AtlasCodeGraphLoadJudgment.spokenScreen(
            repo: model.repo,
            face: graphScreenFace
        )
    }

    static let codeScreenHint = "mapa governado; pílula e proveniência só com dados publicados"
}

extension AtlasCodeView {
    struct WhyFileTarget: Identifiable {
        let path: String
        var id: String { path }
    }

    /// As âncoras que EXISTEM nesta janela do grafo.
    ///
    /// A resposta cita commits do repositório inteiro; a tela carrega 200. Um
    /// commit de três meses atrás é âncora legítima e não está aqui. Sem cruzar
    /// os dois, a tela apagava o mapa inteiro enquanto a pílula anunciava acesos.
    /// Interseção vazia = o mapa não finge: fica inteiro.
// MARK: - Anchors / legend
    var visibleAnchors: Set<String> {
        guard askModel.isAnchoring, let nodes = model.graph?.nodes else { return [] }
        return askModel.anchors.intersection(nodes.map(\.hash))
    }

    /// O que a pílula diz sobre o mapa — contado no que ACENDEU.
    ///
    /// Três estados, três frases, nenhuma inventada:
    /// - nada ancorado → convite;
    /// - âncoras acesas → quantas, e quantas a resposta citou ao todo;
    /// - âncoras todas fora desta janela → dizer isso (mapa intacto ≠ pergunta ignorada).
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

extension AtlasCodeView {
    /// Swipe ou “perguntar” na proveniência: refina a pílula, NÃO abre modal.
// MARK: - Ask focus actions
    func anchorAskOnCommit(_ node: AtlasCodeGraphNode) {
        selectedNode = nil
        askFocusNode = node
        let legend = swipeFocusLegend(node)
        askModel.setSheetFocusLegend(legend)
        askDraft = "o que o commit \(citedCommitPrefix(node)) fez, e por quê?"
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
    }

    /// Compat: CTA da folha de proveniência = mesma âncora (sem sheet de ask).
    func openAskFromProvenance(_ node: AtlasCodeGraphNode) {
        anchorAskOnCommit(node)
    }

    func clearAskFocus() {
        askFocusNode = nil
        askDraft = ""
        askModel.setSheetFocusLegend(nil)
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
}

extension AtlasCodeView {
    /// Lei 7: a pílula nunca some — nem aqui. E agora ela responde.
// MARK: - Ask pill chrome
    var askPill: some View {
        askPillA11yTraits(
            askPillPaddingAnimation(
                askPillTapGesture(askPillContent)
            )
        )
    }

    @ViewBuilder
    var askPillContent: some View {
        // WAVE-016: AgenticPillFace + trailing clear/chevron (âncora WAVE-001).
        AgenticPillFace(invite: anchorLegend ?? AtlasCodeAskContext.invite) {
            askPillClearButton
            Image(systemName: "chevron.up")
                .atlasSans(10, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
        .accessibilityIdentifier(A11yID.codeAskAnchorNote)
        .contentShape(Capsule())
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
            }
            .buttonStyle(.plain)
            .accessibilityLabel(AtlasCodeAskPillJudgment.clearCommitRefLabel)
            .accessibilityHint("Remove o commit da pílula")
            .accessibilityIdentifier(A11yID.codeAskClear)
        } else if askModel.isAnchoring {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                askModel.clear()
            } label: {
                Text("mostrar tudo")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(AtlasCodeAskPillJudgment.clearLabel)
            .accessibilityHint(AtlasCodeAskPillJudgment.clearHint)
            .accessibilityIdentifier(A11yID.codeAskClear)
        }
    }

    func askPillTapGesture<V: View>(_ content: V) -> some View {
        content.onTapGesture {
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            // Com âncora de swipe, o draft já está semeado — não apagar.
            // Sem swipe: emptyPrompt volta ao convite genérico (limpa legenda residual).
            if askFocusNode == nil {
                askDraft = ""
                askModel.setSheetFocusLegend(nil)
            } else {
                askModel.setSheetFocusLegend(anchorLegend)
            }
            showsAskCard = true
        }
    }

    func askPillPaddingAnimation<V: View>(_ content: V) -> some View {
        content
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.bottom, 10)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 0.22),
                value: AtlasCodeAskPillJudgment.phaseID(
                    isAnchoring: pillIsAnchoring,
                    anchorLegend: anchorLegend
                )
            )
    }

    func askPillA11yTraits<Content: View>(_ content: Content) -> some View {
        let face = AtlasCodeAskPillJudgment.face(
            isAnchoring: pillIsAnchoring,
            anchorLegend: anchorLegend
        )
        return content
            .accessibilityElement(children: .contain)
            .accessibilityLabel(
                AtlasCodeAskPillJudgment.spokenPill(
                    isAnchoring: pillIsAnchoring,
                    anchorLegend: anchorLegend
                )
            )
            .accessibilityValue(face.productWord)
            .accessibilityHint(AtlasCodeAskPillJudgment.pillHint)
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier(A11yID.codeAskPill)
    }
}

// MARK: - Body

extension AtlasCodeView {
    func codeScreenChrome<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .background(NavigationInteractivePopEnabler())
            .accessibilityIdentifier(A11yID.codeScreen)
            .accessibilityLabel(spokenCodeScreenLabel())
            .accessibilityValue(graphScreenFace.productWord)
            .accessibilityHint(Self.codeScreenHint)
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
            // WAVE-028: default attention slice once scan is known (operator override freezes).
            .onChange(of: model.phase) { _, phase in
                if case .loaded = phase {
                    applyGraphJudgmentDefaultIfNeeded()
                }
            }
            .onChange(of: model.scanState) { _, _ in
                applyGraphJudgmentDefaultIfNeeded()
            }
    }

    func applyGraphJudgmentDefaultIfNeeded() {
        guard !graphFilterTouchedByOperator else { return }
        guard case .loaded = model.phase else { return }
        let next = AtlasCodeGraphJudgment.defaultFilter(
            scan: model.scanState,
            violatingSignalCount: model.violations?.violations.count ?? 0
        )
        if graphStateFilter != next {
            graphStateFilter = next
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

// MARK: - Route entry AtlasCodeView

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
    /// WAVE-028: operator chip override freezes auto attention slice.
    @State var graphFilterTouchedByOperator = false
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

// MARK: - Mirror card

struct AtlasCodeMirrorCard: View {
    let response: AtlasCodeMirrorResponse
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            headline
            blockedRulesRow
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background, in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.card))
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).strokeBorder(borderColor, lineWidth: 1))
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: mirrorStatePhaseID)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenMirrorLabel())
        .accessibilityHint(Self.mirrorHint)
        .accessibilityIdentifier(A11yID.codeMirror)
    }

    // MARK: - Headline (silence-when-healthy = quiet tone, no decorative check spam)

    @ViewBuilder
    var headline: some View {
        switch response.state {
        case .blocked:
            label(
                "segredo detectado · nada sai da máquina",
                color: AtlasCodePalette.alert,
                icon: "exclamationmark.triangle"
            )
        case .mirrored:
            label("tudo espelhado · a verdade fica no Mac", color: AtlasTheme.textSecondary, icon: "checkmark")
        case .pending(let commits):
            label(
                commits == 1 ? "1 commit ainda só no Mac" : "\(commits) commits ainda só no Mac",
                color: AtlasTheme.textSecondary,
                icon: "internaldrive"
            )
        case .noMirror:
            label("sem espelho configurado", color: AtlasTheme.textTertiary, icon: "circle.dashed")
        case .unknown:
            label("espelho ainda não conhecido", color: AtlasTheme.textTertiary, icon: "questionmark.circle")
        }
    }

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

    var background: Color {
        if case .blocked = response.state { return AtlasCodePalette.alert.opacity(0.05) }
        return AtlasTheme.surface.opacity(0.4)
    }

    var borderColor: Color {
        if case .blocked = response.state { return AtlasCodePalette.alert.opacity(0.35) }
        return AtlasTheme.separator
    }

    // MARK: - A11y

    var mirrorStatePhaseID: String {
        switch response.state {
        case .pending(let commits): return "pending-\(commits)"
        case .blocked(let rules): return "blocked-\(rules.joined(separator: "-"))"
        case .mirrored: return "mirrored"
        case .noMirror: return "no-mirror"
        case .unknown: return "unknown"
        }
    }

    func spokenMirrorLabel() -> String {
        var parts: [String] = ["Espelho"]
        parts.append(contentsOf: spokenMirrorStateParts())
        if let host = response.mirror?.host, !host.isEmpty {
            parts.append("host \(host)")
        }
        return parts.joined(separator: ", ")
    }

    func spokenMirrorStateParts() -> [String] {
        switch response.state {
        case .mirrored:
            return ["tudo espelhado, verdade no Mac"]
        case .noMirror:
            return ["sem espelho configurado"]
        case .unknown:
            return ["estado ainda não conhecido"]
        case .pending(let commits):
            return ["\(commits) commit\(commits == 1 ? "" : "s") ainda só no Mac"]
        case .blocked(let rules):
            var parts = ["bloqueado, segredo detectado"]
            if !rules.isEmpty {
                parts.append("regras \(rules.joined(separator: ", "))")
            }
            return parts
        }
    }

    static let mirrorHint = "cópia remota do repositório e varredura de segredos no Mac"
}

// MARK: - AtlasCodeSurfaceGraph

// MARK: - Host

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

// MARK: - Body

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

// MARK: - AtlasCodeSheetsModifiers

// MARK: - Host

struct AtlasCodeAskWhySheetsModifier: ViewModifier {
  let session: AtlasSession
  let model: AtlasCodeModel
  let provenanceModel: AtlasCodeProvenanceModel
  let askModel: AtlasCodeAskModel
  let graphStateFilter: AtlasCodeGraphStateFilter
  @Binding var askFocusNode: AtlasCodeGraphNode?
  @Binding var showsAskCard: Bool
  @Binding var whyFileTarget: AtlasCodeView.WhyFileTarget?
  @Binding var askThreadId: ThreadID?
  @Binding var askDraft: String

  func body(content: Content) -> some View {
    askWhyWhySheet(on: askWhyAskSheet(on: content))
  }
}

extension AtlasCodeAskWhySheetsModifier {
    var askConversationSheet: some View {
        ConversationView(
            client: session.client,
            threadId: askThreadId,
            title: "Código · \(model.repo)",
            emptyPrompt: AtlasCodeAskContext.emptyPrompt(focusLegend: askModel.sheetFocusLegend),
            emptySuggestions: AtlasCodeAskContext.emptySuggestions,
            taskKind: "code",
            workspace: model.repo,
            draft: askDraft,
            turnFacts: { question in
                // WAVE-019: occasion pack first; optional server ask facts append.
                // WAVE-167: provenance phase for focused commit honesty.
                let focus = askFocusNode
                let server = await askModel.facts(for: question)
                return AtlasCodeAskContext.facts(
                    model: model,
                    focusNode: focus,
                    focusLegend: askModel.sheetFocusLegend,
                    isAnchoring: askModel.isAnchoring,
                    graphStateFilter: graphStateFilter,
                    serverAskFacts: server,
                    provenancePhase: provenanceModel.phase
                )
            },
            onThread: { askThreadId = $0 },
            hidesNavigationBack: true
        )
        .agenticAskSheetPresentation()
        .interactiveDismissDisabled(false)
    }
}

extension AtlasCodeAskWhySheetsModifier {
    func askWhyAskSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showsAskCard) {
                askConversationSheet
            }
    }
}

extension AtlasCodeAskWhySheetsModifier {
    func askWhyWhySheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $whyFileTarget) { target in
                AtlasCodeWhySheet(client: session.client, repo: model.repo, file: target.path)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
    }
}


extension AtlasCodeSheetsModifier {
  @ViewBuilder
  func healReceiptSheet<Content: View>(on content: Content) -> some View {
    content
      .sheet(isPresented: $showsHealReceipt) {
        if let heal = model.heal {
          // WAVE-048: pass undoError; sheet stays open so failure is honest.
          AtlasCodeHealReceiptSheet(
            heal: heal,
            undoError: model.undoError
          ) {
            Task { await model.undoLastHeal() }
          }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
      }
  }

  @ViewBuilder
  func provenanceAndHealSheets<Content: View>(on content: Content) -> some View {
    healReceiptSheet(on: provenanceSheetBind(on: content))
  }
}

extension AtlasCodeSheetsModifier {
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
}

extension AtlasCodeSheetsModifier {
    func provenanceSheetPresent<Content: View>(_ sheet: Content) -> some View {
        sheet
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
    }
}

extension AtlasCodeSheetsModifier {
    @ViewBuilder
    func provenanceSheetBind<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $selectedNode) { node in
                provenanceSheetPresent(provenanceSheetContent(for: node))
            }
    }
}

struct AtlasCodeSheetsModifier: ViewModifier {
  let session: AtlasSession
  let model: AtlasCodeModel
  let provenanceModel: AtlasCodeProvenanceModel
  let askModel: AtlasCodeAskModel
  let graphStateFilter: AtlasCodeGraphStateFilter
  @Binding var selectedNode: AtlasCodeGraphNode?
  @Binding var askFocusNode: AtlasCodeGraphNode?
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
      provenanceModel: provenanceModel,
      askModel: askModel,
      graphStateFilter: graphStateFilter,
      askFocusNode: $askFocusNode,
      showsAskCard: $showsAskCard,
      whyFileTarget: $whyFileTarget,
      askThreadId: $askThreadId,
      askDraft: $askDraft
    ))
  }
}

// MARK: - Body

extension View {
  func atlasCodeSheets(
    session: AtlasSession,
    model: AtlasCodeModel,
    provenanceModel: AtlasCodeProvenanceModel,
    askModel: AtlasCodeAskModel,
    graphStateFilter: AtlasCodeGraphStateFilter,
    selectedNode: Binding<AtlasCodeGraphNode?>,
    askFocusNode: Binding<AtlasCodeGraphNode?>,
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
      graphStateFilter: graphStateFilter,
      selectedNode: selectedNode,
      askFocusNode: askFocusNode,
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
            graphStateFilter: graphStateFilter,
            selectedNode: $selectedNode,
            askFocusNode: $askFocusNode,
            showsHealReceipt: $showsHealReceipt,
            showsAskCard: $showsAskCard,
            whyFileTarget: $whyFileTarget,
            askThreadId: $askThreadId,
            askDraft: $askDraft,
            onProvenanceAsk: openAskFromProvenance
        )
    }
}

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
        graphFilterTouchedByOperator = false
        graphStateFilter = .all

        model.adoptRepo(slug)
        provenanceModel.adoptRepo(slug)
        mirrorModel.adoptRepo(slug)
        askModel.adoptRepo(slug) // also clears sheetFocusLegend

        async let graphLoad: Void = model.load()
        async let mirrorLoad: Void = mirrorModel.refresh()
        await graphLoad
        await mirrorLoad
        applyGraphJudgmentDefaultIfNeeded()
    }
}

extension AtlasCodeView {
    var codeToolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Grafo")
                .font(AtlasFont.serif(20))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
        }
    }

    /// Troca de repositório — Liquid Glass, sempre abaixo do título.
    var repoSwitcher: some View {
        Button {
            showsRepoPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(model.repo)
                    .font(AtlasFont.mono(10.5))
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .semibold))
                    .opacity(0.55)
            }
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .atlasGlassCapsule()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AtlasCodeGraphJudgment.spokenRepoTitle(model.repo))
        .accessibilityHint("troca de repositório")
        .accessibilityIdentifier(A11yID.codeRepoSwitcher)
    }
}
