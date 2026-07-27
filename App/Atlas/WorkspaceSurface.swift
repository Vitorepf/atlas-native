import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: WorkspaceSurface + WorkspaceView entry fused

// MARK: - Host

extension WorkspaceView {
    /// WAVE-073: exclusive workspace face from published shell + counts.
    var workspaceScreenFace: WorkspaceScreenFace {
        WorkspaceJudgment.face(
            showsLoadingShell: showsLoadingShell,
            showsNetworkFailure: showsNetworkFailure,
            threadCount: threads.count
        )
    }

    func spokenWorkspaceScreenLabel() -> String {
        WorkspaceJudgment.spokenScreen(
            title: title,
            face: workspaceScreenFace,
            areaLabel: area.label
        )
    }

    var spokenWorkspaceScreenHint: String {
        WorkspaceJudgment.spokenScreenHint(freeOnly: freeOnly)
    }
}

extension WorkspaceView {
    var workspaceBodyStack: some View {
        ZStack(alignment: .bottom) {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                if !showsNetworkFailure && !showsLoadingShell && hasThreadsToFilter {
                    areaFilter
                }
                listView
            }
            if !showsNetworkFailure && !showsLoadingShell {
                newPill
            }
        }
    }
}

extension WorkspaceView {
    func workspaceScreenChrome<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier(A11yID.workspaceScreen)
            .accessibilityLabel(spokenWorkspaceScreenLabel())
            .accessibilityValue(workspaceScreenFace.productWord)
            .accessibilityHint(spokenWorkspaceScreenHint)
    }
}

extension WorkspaceView {
    /// Header composto (reconstruído pós-merge: o peel deixou só as folhas).
    var header: some View {
        HStack(spacing: 12) {
            headerBackButton
            Spacer()
            Text(title)
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityLabel(headerSpokenTitle)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    var headerBackButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40).atlasGlassCircle()
        }
        .accessibilityLabel(WorkspaceJudgment.spokenBack)
    }

    var headerSpokenTitle: String {
        WorkspaceJudgment.spokenHeaderTitle(title: title, freeOnly: freeOnly)
    }
}

extension WorkspaceView {
    var areaFilterChipRow: some View {
        HStack(spacing: 8) {
            ForEach(AtlasArea.allCases) { a in
                areaFilterChip(a, active: a == area)
            }
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
    }
}

extension WorkspaceView {
    var areaFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            areaFilterChipRow
        }
        .atlasScrollEdgeFade()
        .padding(.vertical, 10)
        .accessibilityIdentifier(A11yID.workspaceAreaFilter)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: area)
    }
}

extension WorkspaceView {
    func areaFilterChip(_ a: AtlasArea, active: Bool) -> some View {
        Button {
            if reduceMotion {
                area = a
            } else {
                withAnimation(AtlasMotion.editorial) { area = a }
            }
        } label: {
            areaFilterChipLabel(a, active: active)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(WorkspaceJudgment.spokenAreaFilter(a.label))
        .accessibilityHint(WorkspaceJudgment.spokenAreaFilterHint)
        .accessibilityAddTraits(active ? .isSelected : [])
    }
}

extension WorkspaceView {
    func areaFilterChipLabel(_ a: AtlasArea, active: Bool) -> some View {
        Text(a.label)
            .font(.system(.subheadline, weight: .medium))
            .padding(.horizontal, 14).padding(.vertical, 8)
            .atlasChipSelection(active)
    }
}

extension WorkspaceView {
    var newPill: some View {
        // A conversa nova nasce NESTE workspace (livres → sem workspace).
        // WAVE-016: face canônica AgenticPillFace (sem hand-roll chrome).
        NavigationLink(value: Route.new(workspaceKey: freeOnly ? nil : workspaceKey)) {
            AgenticPillFace(invite: workspacePillInvite)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(WorkspaceJudgment.productNewConversation)
        .accessibilityHint(WorkspaceJudgment.spokenNewConversationHint)
        .accessibilityIdentifier(A11yID.workspaceNewPill)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            // Quarto e último consumidor do véu compartilhado.
            AtlasTheme.bottomVeil()
                .ignoresSafeArea()
        )
    }

    private var workspacePillInvite: String {
        if freeOnly {
            return WorkspaceAskContext.productFreeInvite
        }
        if let workspaceKey {
            return WorkspaceAskContext.productInvite(workspaceName: title.isEmpty ? workspaceKey : title)
        }
        return HomeAskContext.productInvite
    }
}

// MARK: - Thread rows
extension WorkspaceThreadsSection {
    @ViewBuilder
    func threadRowLoop(_ t: AtlasAiThread, newBadgeSuppressed: Bool = false) -> some View {
        // Esta lista é de um workspace só: pintar todas as linhas do mesmo tom
        // não agrupa nada. O trilho fica para a busca, onde eles se misturam.
        WorkspaceThreadLink(
            thread: t,
            reduceMotion: reduceMotion,
            newBadgeSuppressed: newBadgeSuppressed,
            showsWorkspaceTint: false
        )
        threadRowSeparator(after: t)
    }
}

extension WorkspaceThreadsSection {
    @ViewBuilder
    func threadRowSeparator(after thread: AtlasAiThread) -> some View {
        if thread.id != threads.last?.id {
            Divider().overlay(AtlasTheme.separator)
                .padding(.leading, AtlasTheme.Space.screen + 36)
        }
    }
}

extension WorkspaceThreadsSection {
    /// Badge "novo" saturado (maioria de 6+ linhas) perde o poder de
    /// discriminar — silencia em bloco; a ordenação já diz recência.
    var newBadgeSaturated: Bool {
        threads.count >= 6
            && threads.lazy.filter(ConversationModel.hasNewerContent).count * 2 > threads.count
    }

    @ViewBuilder
    var threadRows: some View {
        let saturated = newBadgeSaturated
        ForEach(threads) { t in
            threadRowLoop(t, newBadgeSuppressed: saturated)
        }
    }
}

// MARK: - Threads section
struct WorkspaceThreadsSection: View {
    let threads: [AtlasAiThread]
    let area: AtlasArea
    let screenTitle: String
    let reduceMotion: Bool

    var body: some View {
        Group {
            captionHeader
            threadRows
        }
    }
}

extension WorkspaceThreadsSection {
    var caption: String {
        if area == .tudo {
            return "\(threads.count) conversa\(threads.count == 1 ? "" : "s")"
        }
        return "\(threads.count) em \(area.label)"
    }
}

extension WorkspaceThreadsSection {
    var spokenCaption: String {
        if area == .tudo {
            return "\(threads.count) conversa\(threads.count == 1 ? "" : "s") em \(screenTitle)"
        }
        return "\(threads.count) conversa\(threads.count == 1 ? "" : "s") em \(area.label), \(screenTitle)"
    }
}

extension WorkspaceThreadsSection {
    var captionHeader: some View {
        Text(caption.uppercased())
            .font(AtlasFont.mono(10, .semibold)).tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(spokenCaption)
            .accessibilityIdentifier(A11yID.workspaceThreadsCaption)
    }
}

// MARK: - Workspace list shell
extension WorkspaceView {
    var showsLoadingShell: Bool {
        guard session.threads.isEmpty else { return false }
        switch session.phase {
        case .idle, .loading: return true
        default: return false
        }
    }
}

extension WorkspaceView {
    /// Sessão sem threads e load falhou → offline/rede, não "vazio editorial".
    var showsNetworkFailure: Bool {
        guard session.threads.isEmpty else { return false }
        if case .failed = session.phase { return true }
        return false
    }
}

extension WorkspaceView {
    var listView: some View {
        ScrollView {
            workspaceListChrome(
                LazyVStack(spacing: 0) {
                    scrollPhaseContent
                }
            )
        }
        .scrollIndicators(.hidden)
        .refreshable { await session.loadThreads() }
    }
}

extension WorkspaceView {
    func workspaceListChrome<Content: View>(_ content: Content) -> some View {
        content
            .atlasDockReserve()
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: area)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: threads.map(\.id))
    }
}

extension WorkspaceView {
    var listNetworkFailure: some View {
        AtlasNetworkFailureEmpty(
            kind: session.failureKind,
            hasToken: session.hasToken,
            host: session.host,
            retryHint: WorkspaceJudgment.spokenReloadConversationsHint,
            retryAccessibilityIdentifier: A11yID.workspaceRetry,
            accessibilityIdentifier: A11yID.workspaceOffline,
            onRetry: { Task { await session.loadThreads() } }
        )
    }
}

extension WorkspaceView {
    @ViewBuilder
    var listLoadedContent: some View {
        if threads.isEmpty {
            WorkspaceEditorialEmpty(area: area, freeOnly: freeOnly, screenTitle: title)
        } else {
            WorkspaceThreadsSection(
                threads: threads,
                area: area,
                screenTitle: title,
                reduceMotion: reduceMotion
            )
        }
    }
}

extension WorkspaceView {
    @ViewBuilder
    var scrollPhaseContent: some View {
        if showsLoadingShell {
            AtlasListSkeleton(reduceMotion: reduceMotion)
                .accessibilityIdentifier(A11yID.workspaceLoading)
        } else if showsNetworkFailure {
            listNetworkFailure
        } else {
            listLoadedContent
        }
    }
}


/// Esqueleto da lista enquanto o servidor não responde.
///
/// NÃO é mock: nenhuma linha inventa título, contagem ou data — são barras
/// neutras. O que ele antecipa é a FORMA, e usa a métrica exata da
/// `ThreadRow` (mesmo padding, mesma altura de título e subtítulo). Sem isso
/// o conteúdo real "pula" ao chegar, que é pior que esperar.
struct AtlasListSkeleton: View {
    var rows: Int = 5
    var reduceMotion: Bool
    @State private var shimmer = false

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rows, id: \.self) { i in
                row(index: i)
                if i < rows - 1 {
                    Divider().overlay(AtlasTheme.separator)
                        .padding(.leading, AtlasTheme.Space.screen + 36)
                }
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(AtlasMotion.breath(1.1)) { shimmer = true }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("carregando conversas")
    }

    private func row(index: Int) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(AtlasTheme.surface)
                .frame(width: 18, height: 18)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 6) {
                bar(width: index.isMultiple(of: 2) ? 0.62 : 0.48, height: 13)
                bar(width: 0.30, height: 10)
            }
            Spacer(minLength: 8)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.vertical, AtlasTheme.Space.row)
        .opacity(shimmer ? 0.85 : 0.45)
    }

    private func bar(width: CGFloat, height: CGFloat) -> some View {
        GeometryReader { geo in
            Capsule()
                .fill(AtlasTheme.surface)
                .frame(width: geo.size.width * width, height: height)
        }
        .frame(height: height)
    }
}

// MARK: - Thread link
struct WorkspaceThreadLink: View {
    let thread: AtlasAiThread
    let reduceMotion: Bool
    var newBadgeSuppressed: Bool = false
    var showsWorkspaceTint: Bool = true
    @Environment(AtlasSession.self) private var session

    var isRunning: Bool {
        WorkspaceThreadJudgment.isRunning(
            thread: thread,
            remote: session.remoteLiveSessions
        )
    }

    var body: some View {
        threadLinkA11y
    }
}

extension WorkspaceThreadLink {
    var threadLinkA11y: some View {
        NavigationLink(value: Route.thread(id: ThreadID(thread.id), title: thread.title)) {
            ThreadRow(
                thread: thread,
                newBadgeSuppressed: newBadgeSuppressed,
                showsWorkspaceTint: showsWorkspaceTint
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(SearchListJudgment.spokenRow(thread: thread))
        .accessibilityHint(WorkspaceThreadJudgment.spokenThreadHint(isRunning: isRunning))
        .accessibilityIdentifier(A11yID.workspaceThread(thread.id))
        .transition(threadTransition)
    }
}

extension WorkspaceThreadLink {
    var threadTransition: AnyTransition {
        reduceMotion ? .opacity : .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 6)),
            removal: .opacity
        )
    }
}

extension WorkspaceView {
    var threads: [AtlasAiThread] {
        let base = freeOnly
            ? session.threads.filter { $0.workspace == nil }
            : session.threads(inWorkspace: workspaceKey)
        let filtered = area == .tudo ? base : base.filter { AtlasArea.of($0) == area }
        // WAVE-032: live-first attention (threadId), same helper as Search.
        return WorkspaceThreadJudgment.rank(filtered, remote: session.remoteLiveSessions)
    }

    /// Filtro só existe quando há o que filtrar: chips numa lista vazia
    /// são ruído (regra da casa: controle sem efeito não aparece).
    var hasThreadsToFilter: Bool {
        freeOnly
            ? session.threads.contains { $0.workspace == nil }
            : !session.threads(inWorkspace: workspaceKey).isEmpty
    }
}

// MARK: - Route entry WorkspaceView

struct WorkspaceView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let workspaceKey: String?
    let title: String
    /// Modo sem projeto: só conversas com workspace nulo (perguntas, pesquisas,
    /// pensamento livre — o uso GPT-no-iPhone). O projeto é opcional, não regra.
    var freeOnly: Bool = false
    @State var area: AtlasArea = .tudo

    var body: some View {
        workspaceScreenChrome(workspaceBodyStack)
    }
}

// MARK: - Row host

struct ThreadRow: View {
    let thread: AtlasAiThread
    var newBadgeSuppressed: Bool = false
    /// Numa lista de um workspace só, todas as linhas teriam o mesmo tom — o
    /// trilho vira ruído em vez de agrupar. Só a lista mista o acende.
    var showsWorkspaceTint: Bool = true
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dynamicTypeSize) var typeSize
    @Environment(AtlasSession.self) private var session

    /// Nos tamanhos de acessibilidade o selo, a idade e o chevron comiam a
    /// largura e sobrava "Impl…" de título. Aí a linha empilha: título com a
    /// largura toda em cima, meta embaixo.
    var stacksForAccessibility: Bool { typeSize.isAccessibilitySize }

    /// WAVE-032: threadId-first running signal (title fallback only if no id).
    var isRunning: Bool {
        WorkspaceThreadJudgment.isRunning(
            thread: thread,
            remote: session.remoteLiveSessions
        )
    }
    var isNew: Bool { !newBadgeSuppressed && ConversationModel.hasNewerContent(thread) }
    var workspaceTint: Color? {
        guard showsWorkspaceTint else { return nil }
        return thread.workspace.map(threadWorkspaceColor)
    }

    var body: some View {
        rowContent
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                WorkspaceThreadJudgment.threadSpoken(
                    title: thread.title,
                    messageCount: thread.messageCount,
                    isRunning: isRunning,
                    isNew: isNew,
                    hasWorkspace: workspaceTint != nil
                )
            )
            .accessibilityHint(WorkspaceThreadJudgment.spokenThreadHint(isRunning: isRunning))
    }

    var rowContent: some View {
        // Empilhado, o bloco tem 3+ linhas: centrado o ícone flutuava no meio.
        HStack(alignment: stacksForAccessibility ? .top : .center, spacing: 14) {
            rowLead
            rowTextStack
            if !stacksForAccessibility {
                Spacer(minLength: 8)
                rowTrailing
            }
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .overlay(alignment: .leading) { rowWorkspaceTint }
        .contentShape(Rectangle())
    }

    var rowTextStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(thread.title).font(AtlasFont.serif(16)).foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(stacksForAccessibility ? 3 : 1)
                .truncationMode(.tail)
            // Títulos gerados repetem entre si ("Implement a concrete…");
            // sem esta linha a lista fica indistinguível item a item.
            Text(WorkspaceThreadJudgment.rowSubtitle(thread: thread, showsWorkspace: showsWorkspaceTint))
                .atlasSans(12)
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(stacksForAccessibility ? 2 : 1)
                .truncationMode(.tail)
            if stacksForAccessibility {
                HStack(spacing: 8) { rowTrailing }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    var rowLead: some View {
        if isRunning {
            BreathingDiamond(size: 9, reduceMotion: reduceMotion).frame(width: 22)
                .accessibilityHidden(true)
        } else {
            Image(systemName: "bubble.left")
                .atlasSans(17).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    var rowWorkspaceTint: some View {
        if let workspaceTint {
            // Encostado em x=0 o trilho era cortado pela borda da tela; com o
            // inset ele lê como marca da linha, não como sangria.
            Capsule()
                .fill(workspaceTint.opacity(0.85))
                .frame(width: 3)
                .padding(.vertical, 10)
                .padding(.leading, 6)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    var rowTrailing: some View {
        newThreadBadge
        if isRunning {
            Text(WorkspaceThreadJudgment.productExecuting).font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        } else if let age = WorkspaceThreadJudgment.rowAge(thread: thread) {
            // Quando o título não distingue, a idade distingue. A contagem de
            // mensagens migrou para o subtítulo, onde tem rótulo.
            Text(age)
                .atlasSans(12)
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
        Image(systemName: "chevron.right")
            .atlasSans(12, .semibold).foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    var newThreadBadge: some View {
        if isNew && !isRunning {
            Text("novo")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.accent)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(AtlasTheme.goldVeil))
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Host

struct AtlasWorkspacePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @State var model: AtlasCodeWorkspaceModel
    @State var query = ""
    let title: String
    let onNoRepo: (() -> Void)?
    let onPick: (_ key: String, _ title: String) -> Void

    init(
        client: AtlasClient,
        title: String = "Adicionar workspace",
        onNoRepo: (() -> Void)? = nil,
        onPick: @escaping (_ key: String, _ title: String) -> Void
    ) {
        _model = State(initialValue: AtlasCodeWorkspaceModel(client: client))
        self.title = title
        self.onNoRepo = onNoRepo
        self.onPick = onPick
    }

    private var showsNoRepo: Bool { onNoRepo != nil && query.isEmpty }

    private var pickerRepos: [AtlasCodeRepoRef] {
        WorkspacePickerJudgment.repos(from: model.workspace, query: query)
    }

    private var pickerFace: WorkspacePickerFace {
        WorkspacePickerJudgment.face(
            phase: model.phase,
            repoCount: pickerRepos.count,
            query: query
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showsNoRepo { noRepoRow }
                pickerContent
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: WorkspacePickerJudgment.productSearchPrompt)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(WorkspacePickerJudgment.spokenClose) { dismiss() }
                        .atlasSans(15, .medium)
                        .tint(AtlasTheme.textSecondary)
                }
            }
            .task { if case .idle = model.phase { await model.load() } }
            .accessibilityIdentifier(A11yID.workspacePickerSheet)
            .accessibilityValue(pickerFace.productWord)
            .accessibilityLabel(
                WorkspacePickerJudgment.spokenSheet(face: pickerFace, title: title)
            )
        }
    }

    @ViewBuilder
    private var pickerContent: some View {
        switch pickerFace {
        case .loading:
            VStack(spacing: 12) {
                BreathingDiamond(size: 10, reduceMotion: false)
                Text(WorkspacePickerJudgment.productLoadingCopy)
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel(WorkspacePickerJudgment.spokenLoading())
        case .failed:
            VStack(spacing: 10) {
                Text(WorkspacePickerJudgment.productFailedHeadline)
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Button(WorkspacePickerJudgment.productRetry) { Task { await model.load() } }
                    .atlasSans(15, .medium)
                    .foregroundStyle(AtlasTheme.accent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel(WorkspacePickerJudgment.spokenFailed())
        case .empty, .miss, .list:
            pickerRepoList
        }
    }
}

extension AtlasWorkspacePickerSheet {
    var noRepoRow: some View {
        Button {
            onNoRepo?()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "bubble.left")
                    .atlasSans(15)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 22)
                VStack(alignment: .leading, spacing: 2) {
                    Text(WorkspacePickerJudgment.productNoRepoTitle).atlasSans(15, .medium)
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text(WorkspacePickerJudgment.productNoRepoSubtitle).atlasSans(12)
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                Spacer()
                Image(systemName: "chevron.right").atlasSans(12, .semibold)
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.horizontal, 14).padding(.vertical, 14)
            .contentShape(Rectangle())
            .atlasCard()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(WorkspacePickerJudgment.spokenNoRepo())
        .accessibilityHint(WorkspacePickerJudgment.spokenNoRepoHint)
        .accessibilityIdentifier(A11yID.workspacePickerNoRepo)
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 12)
    }

    var pickerRepoList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(WorkspacePickerJudgment.productReposCaption)
                    .font(AtlasFont.mono(10, .medium)).tracking(1.6)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, showsNoRepoSpacing ? 18 : 4)
                VStack(spacing: 0) {
                    ForEach(pickerRepos) { repo in
                        pickerRepoRow(repo)
                        if repo.id != pickerRepos.last?.id {
                            Divider().overlay(AtlasTheme.separatorSoft)
                        }
                    }
                }
                .atlasCard()
                .padding(.horizontal, AtlasTheme.Space.screen)
            }
            .padding(.vertical, 12)
        }
        .accessibilityValue(pickerFace.productWord)
    }

    private var showsNoRepoSpacing: Bool { onNoRepo != nil && query.isEmpty }

    private func pickerRepoRow(_ repo: AtlasCodeRepoRef) -> some View {
        Button {
            onPick(repo.slug, repo.name)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "folder")
                    .atlasSans(15)
                    .foregroundStyle(AtlasTheme.textTertiary)
                HStack(spacing: 0) {
                    if let folder = repo.folder {
                        Text("\(folder)/").atlasSans(15).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    Text(repo.name).atlasSans(15, .medium).foregroundStyle(AtlasTheme.textPrimary)
                }
                .lineLimit(1)
                Spacer()
                if let age = AtlasCodeAge.short(from: repo.lastCommitAt) {
                    Text(age).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(WorkspacePickerJudgment.spokenRow(repo))
        .accessibilityHint(WorkspacePickerJudgment.spokenRowHint)
        .accessibilityIdentifier(A11yID.workspacePickerRow(repo.slug))
    }
}

// MARK: - Types

/// Exclusive Workspace screen face (WAVE-073).
enum WorkspaceScreenFace: Equatable {
    case loading
    case offline
    case empty
    case list(Int)

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .offline: return "offline"
        case .empty: return "empty"
        case .list: return "list"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading: return "carregando"
        case .offline: return "offline"
        case .empty: return "nenhuma conversa neste filtro"
        case .list(let n):
            return n == 1 ? "1 conversa" : "\(n) conversas"
        }
    }
}

// MARK: - Judgment

/// Pure workspace-screen grammar — face · spoken · pack.
enum WorkspaceJudgment {

    static func face(
        showsLoadingShell: Bool,
        showsNetworkFailure: Bool,
        threadCount: Int
    ) -> WorkspaceScreenFace {
        if showsLoadingShell { return .loading }
        if showsNetworkFailure { return .offline }
        if threadCount <= 0 { return .empty }
        return .list(threadCount)
    }

    static func spokenScreen(
        title: String,
        face: WorkspaceScreenFace,
        areaLabel: String
    ) -> String {
        switch face {
        case .loading:
            return "\(title), carregando"
        case .offline:
            return "\(title), offline"
        case .empty:
            return "\(title), nenhuma conversa neste filtro"
        case .list(let n):
            return "\(title), \(n) conversa\(n == 1 ? "" : "s"), filtro \(areaLabel)"
        }
    }

    static func spokenScreenHint(freeOnly: Bool) -> String {
        freeOnly ? "conversas sem workspace" : "conversas deste workspace"
    }

    // MARK: Chrome (header / filter / pill)

    static let spokenReconnectHint = "reconecta ao servidor Atlas"
    static let spokenReloadConversationsHint = "reconecta e recarrega conversas deste workspace"
    static let spokenBack = "voltar"
    static let spokenAreaFilterHint = "filtra conversas já carregadas"
    static let productNewConversation = "nova conversa"
    static let productNewConversationTitle = "Nova conversa"
    static let productConversasTitle = "Conversas"
    static let spokenNewConversationHint = "abre o compositor para escrever ao Atlas"

    static func spokenAreaFilter(_ label: String) -> String {
        "área \(label)"
    }

    static func spokenHeaderTitle(title: String, freeOnly: Bool) -> String {
        freeOnly ? "conversas sem projeto" : title
    }

    static func packFacts(
        title: String,
        showsLoadingShell: Bool,
        showsNetworkFailure: Bool,
        threadCount: Int,
        areaLabel: String,
        freeOnly: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(
            showsLoadingShell: showsLoadingShell,
            showsNetworkFailure: showsNetworkFailure,
            threadCount: threadCount
        )
        facts.append("workspace_face: \(face.productWord)")
        facts.append("workspace_title: \(title)")
        facts.append("workspace_area: \(areaLabel)")
        if freeOnly { facts.append("workspace_free_only: true") }
        switch face {
        case .loading:
            absences.append("workspace ainda carregando")
        case .offline:
            absences.append("workspace offline")
        case .empty:
            absences.append("nenhuma conversa neste filtro")
            facts.append("workspace_threads: 0")
        case .list(let n):
            facts.append("workspace_threads: \(n)")
        }
        return (facts, absences)
    }
}
// MARK: - Types

/// Exclusive workspace editorial-empty face (WAVE-078).
enum WorkspaceEmptyFace: Equatable {
    case area(String)
    case free
    case workspace(String)

    var productWord: String {
        switch self {
        case .area: return "area"
        case .free: return "free"
        case .workspace: return "workspace"
        }
    }

    var spokenFace: String {
        switch self {
        case .area(let label):
            return "nada em \(label)"
        case .free:
            return "nenhuma conversa sem projeto ainda"
        case .workspace(let title):
            return "nenhuma conversa em \(title) ainda"
        }
    }
}

// MARK: - Judgment

/// Pure workspace editorial-empty grammar — face · copy · pack.
enum WorkspaceEmptyJudgment {

    static func face(
        area: AtlasArea,
        freeOnly: Bool,
        screenTitle: String
    ) -> WorkspaceEmptyFace {
        if area != .tudo {
            return .area(area.label)
        }
        if freeOnly {
            return .free
        }
        return .workspace(screenTitle)
    }

    static func headline(face: WorkspaceEmptyFace) -> String {
        switch face {
        case .area(let label):
            return "Nada em \(label) — por enquanto."
        case .free:
            return "Nenhuma conversa sem projeto ainda."
        case .workspace(let title):
            return "Nenhuma conversa em \(title) ainda."
        }
    }

    static func footnote(face: WorkspaceEmptyFace) -> String {
        switch face {
        case .free:
            return "perguntas e pensamento livre começam abaixo"
        case .area, .workspace:
            return "comece uma abaixo — o projeto é opcional"
        }
    }

    static func spokenLabel(face: WorkspaceEmptyFace) -> String {
        let lead: String
        switch face {
        case .area(let label):
            // Preserve area-in-screenTitle honesty when title known via pack only —
            // spoken lead matches prior: "nada em \(area) em \(screenTitle)" needs title.
            lead = "nada em \(label)"
        case .free:
            lead = face.spokenFace
        case .workspace(let title):
            lead = "nenhuma conversa em \(title) ainda"
        }
        return "\(lead). \(footnote(face: face))"
    }

    /// Full spoken with screen title for area case (prior honesty).
    static func spokenLabel(
        area: AtlasArea,
        freeOnly: Bool,
        screenTitle: String
    ) -> String {
        let face = face(area: area, freeOnly: freeOnly, screenTitle: screenTitle)
        switch face {
        case .area(let label):
            return "nada em \(label) em \(screenTitle). \(footnote(face: face))"
        default:
            return spokenLabel(face: face)
        }
    }

    static func packFacts(
        area: AtlasArea,
        freeOnly: Bool,
        screenTitle: String
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(area: area, freeOnly: freeOnly, screenTitle: screenTitle)
        facts.append("workspace_empty_face: \(face.productWord)")
        facts.append("workspace_empty_area: \(area.label)")
        facts.append("workspace_empty_title: \(screenTitle)")
        if freeOnly { facts.append("workspace_empty_free_only: true") }
        absences.append("nenhuma conversa neste recorte vazio")
        return (facts, absences)
    }
}
// MARK: - WorkspaceEmptyChrome

struct WorkspaceEditorialEmpty: View {
    let area: AtlasArea
    let freeOnly: Bool
    let screenTitle: String

    /// WAVE-078: exclusive editorial-empty face.
    var emptyFace: WorkspaceEmptyFace {
        WorkspaceEmptyJudgment.face(
            area: area, freeOnly: freeOnly, screenTitle: screenTitle
        )
    }

    var body: some View {
        editorialGlyph
    }

    var editorialGlyph: some View {
        AtlasEditorialGlyphEmpty(
            headline: headline,
            footnote: footnote,
            accessibilityIdentifier: A11yID.workspaceEmpty,
            spokenLabel: spokenLabel,
            accessibilityValue: emptyFace.productWord
        )
    }

    var headline: String {
        WorkspaceEmptyJudgment.headline(face: emptyFace)
    }

    var footnote: String {
        WorkspaceEmptyJudgment.footnote(face: emptyFace)
    }

    var spokenLabel: String {
        WorkspaceEmptyJudgment.spokenLabel(
            area: area, freeOnly: freeOnly, screenTitle: screenTitle
        )
    }
}

private struct OptionalAccessibilityValue: ViewModifier {
    let value: String?
    func body(content: Content) -> some View {
        if let value {
            content.accessibilityValue(value)
        } else {
            content
        }
    }
}

struct AtlasEditorialGlyphEmpty: View {
    let headline: String
    var footnote: String? = nil
    let accessibilityIdentifier: String
    var spokenLabel: String? = nil
    var accessibilityValue: String? = nil

    var body: some View {
        // Topo fixo em 72pt jogava o vazio para a testa da tela e deixava
        // ~60% morto embaixo. Dentro de ScrollView só o container manda a
        // altura real — daí o containerRelativeFrame em vez de maxHeight.
        editorialStack
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 40)
            .containerRelativeFrame(.vertical, alignment: .center) { height, _ in
                max(320, height * 0.72)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLabel ?? headline)
            .modifier(OptionalAccessibilityValue(value: accessibilityValue))
            .accessibilityIdentifier(accessibilityIdentifier)
    }

    var editorialStack: some View {
        VStack(spacing: 14) {
            editorialGlyph
            editorialCopyStack
        }
    }

    var editorialGlyph: some View {
        Text("✦")
            .font(AtlasFont.serif(24)).foregroundStyle(AtlasTheme.accent.opacity(0.45))
            .accessibilityHidden(true)
    }

    var editorialCopyStack: some View {
        VStack(spacing: 8) {
            Text(headline)
                .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
            if let footnote {
                Text(footnote)
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .accessibilityHidden(true)
            }
        }
    }
}

struct WorkspaceLoadingEmpty: View {
    var reduceMotion: Bool
    var text: String = "abrindo conversas…"
    var spoken: String? = nil
    var topPadding: CGFloat = 72

    var body: some View {
        VStack(spacing: 18) {
            BreathingGlyph(reduceMotion: reduceMotion)
            Text(text)
                .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity).padding(.top, topPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spoken ?? text)
    }
}

struct AtlasNetworkFailureEmpty: View {
    let kind: AtlasNetworkFailureKind?
    let hasToken: Bool
    let host: String
    var topPadding: CGFloat = 56
    var retryHint: String = WorkspaceJudgment.spokenReconnectHint
    var retryAccessibilityIdentifier: String?
    let accessibilityIdentifier: String
    let onRetry: () -> Void

    var body: some View {
        AtlasOpsFailureEmpty(
            mode: .network(kind: kind, hasToken: hasToken, host: host),
            layout: .centered,
            topPadding: topPadding,
            accessibilityIdentifier: accessibilityIdentifier,
            retryAccessibilityIdentifier: retryAccessibilityIdentifier,
            retryHint: retryHint,
            onRetry: onRetry
        )
    }
}
// MARK: - WorkspaceAskContext

enum WorkspaceAskContext {
    static func productInvite(workspaceName: String) -> String {
        "Escreva sobre \(workspaceName)"
    }

    static func emptySuggestions(workspaceName: String, threadCount: Int) -> [String] {
        if threadCount > 0 {
            return [
                "O que está vivo em \(workspaceName)?",
                "Resume as conversas recentes deste workspace",
                "O que preciso julgar aqui?"
            ]
        }
        return [
            "Começa a primeira conversa em \(workspaceName)",
            "O que este workspace precisa agora?",
            "Como organizar o trabalho aqui?"
        ]
    }

    @MainActor
    static func facts(session: AtlasSession, workspaceKey: String) -> String {
        let name = session.workspaces.first(where: { $0.id == workspaceKey })?.name ?? workspaceKey
        let threads = session.threads(inWorkspace: workspaceKey)
        var anchors: [String] = []
        var facts: [String] = []
        var absences: [String] = []

        // WAVE-185: workspace shell pack (key · count · path).
        let shell = WorkspaceThreadJudgment.packShellFacts(
            workspaceKey: workspaceKey,
            displayName: name,
            threadCount: threads.count,
            fullPath: session.workspaceFullPath(forKey: workspaceKey)
        )
        facts.append(contentsOf: shell.facts)
        absences.append(contentsOf: shell.absences)
        anchors.append(contentsOf: shell.anchors)

        for t in threads.prefix(6) {
            let shown = t.title.trimmingCharacters(in: .whitespacesAndNewlines)
            anchors.append(shown.isEmpty ? "thread sem título" : shown)
        }

        // WAVE-186: hub-global live pack (never claim workspace-scoped).
        let hubLive = LiveNowJudgment.packHubFacts(
            live: TurnPresence.shared.liveSessions
        )
        facts.append(contentsOf: hubLive.facts)
        absences.append(contentsOf: hubLive.absences)

        // WAVE-032: live slice of **this** workspace catalog (threadId match).
        let scoped = WorkspaceThreadJudgment.liveInWorkspaceFacts(
            workspaceKey: workspaceKey,
            sessionThreads: threads,
            remote: session.remoteLiveSessions
        )
        facts.append(contentsOf: scoped.facts)
        absences.append(contentsOf: scoped.absences)
        for subject in scoped.subjects {
            anchors.append("live · \(subject)")
        }

        // WAVE-162: workspace screen face organ (loading/offline/empty/list).
        let showsLoading = (session.phase == .loading || session.phase == .idle) && threads.isEmpty
        let showsOffline = {
            if case .failed = session.phase { return threads.isEmpty }
            return false
        }()
        let screenPack = WorkspaceJudgment.packFacts(
            title: name,
            showsLoadingShell: showsLoading,
            showsNetworkFailure: showsOffline,
            threadCount: threads.count,
            areaLabel: "todas",
            freeOnly: false
        )
        facts.append(contentsOf: screenPack.facts)
        absences.append(contentsOf: screenPack.absences)

        // WAVE-166: empty editorial organ when catalog silence.
        if threads.isEmpty {
            let emptyPack = WorkspaceEmptyJudgment.packFacts(
                area: .tudo,
                freeOnly: false,
                screenTitle: name
            )
            facts.append(contentsOf: emptyPack.facts)
            absences.append(contentsOf: emptyPack.absences)
        }

        // WAVE-166: ops failure organ when load failed with empty list.
        if showsOffline {
            let failPack = AtlasOpsFailureJudgment.packFacts(
                mode: .network(kind: session.failureKind ?? .offline, hasToken: session.hasToken, host: session.host)
            )
            facts.append(contentsOf: failPack.facts)
            absences.append(contentsOf: failPack.absences)
        }

        // WAVE-158: can_do matrix — scoped live never invents stop on workspace pack.
        let scopedLiveCount = WorkspaceThreadJudgment.rank(threads, remote: session.remoteLiveSessions)
            .filter { WorkspaceThreadJudgment.isRunning(thread: $0, remote: session.remoteLiveSessions) }
            .count
        let partida = PartidaCanDoJudgment.workspace(scopedLiveCount: scopedLiveCount)
        absences.append(contentsOf: partida.absences)

        return AgenticOccasionPack(
            surface: "workspace",
            subject: name,
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: partida.canDo
        ).render()
    }

    /// Nova conversa livre (sem workspace) — distinta da Home partida.
    static let productFreeInvite = "Escreva livremente"
}
// MARK: - Types

/// Exclusive workspace-picker sheet face (WAVE-097).
enum WorkspacePickerFace: Equatable {
    case loading
    case failed
    case empty
    case list(Int)
    case miss

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .list(let n): return "list(\(n))"
        case .miss: return "miss"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading: return "lendo repositórios"
        case .failed: return "Mac não respondeu"
        case .empty: return "nenhum repositório"
        case .list(let n):
            let noun = n == 1 ? "repositório" : "repositórios"
            return "\(n) \(noun)"
        case .miss: return "nenhum repositório com a busca"
        }
    }
}

// MARK: - Judgment

/// Pure workspace-picker grammar — face · rank · filter · spoken · pack.
enum WorkspacePickerJudgment {

    static let productLoadingCopy = "lendo os repositórios do Mac…"
    static let productFailedHeadline = "O Mac não respondeu."
    static let productRetry = "Tentar de novo"
    static let productNoRepo = "sem repositório"
    static let spokenNoRepoHint = "conversa geral com o Atlas, sem projeto"
    static let productNoRepoTitle = "Sem repositório"
    static let productNoRepoPublished = "o workspace não publicou nenhum repo"
    static let productTryAgainSoon = "tente de novo em instantes"
    static let productNoRepoSubtitle = "conversar ou pesquisar, sem projeto"
    static let productReposCaption = "REPOSITÓRIOS"
    static let productSearchPrompt = "Buscar repositórios"
    static let spokenRowHint = "abre o workspace deste repositório"
    static let productCurrentRepoBadge = "atual"
    static let spokenClose = "Fechar"

    // MARK: Face

    static func face(
        phase: LoadPhase,
        repoCount: Int,
        query: String
    ) -> WorkspacePickerFace {
        switch phase {
        case .idle, .loading:
            return .loading
        case .failed:
            return .failed
        case .loaded:
            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
            if repoCount <= 0 {
                return trimmed.isEmpty ? .empty : .miss
            }
            return .list(repoCount)
        }
    }

    // MARK: Rank / filter

    /// Dedupe by slug; lastCommit desc; name ASC stable.
    static func rank(_ repos: [AtlasCodeRepoRef]) -> [AtlasCodeRepoRef] {
        var seen = Set<String>()
        let unique = repos.filter { seen.insert($0.slug).inserted }
        return unique.enumerated().sorted { lhs, rhs in
            switch (lhs.element.lastCommitAt, rhs.element.lastCommitAt) {
            case let (x?, y?):
                if x != y { return x > y }
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                break
            }
            let nameCmp = lhs.element.name.localizedCaseInsensitiveCompare(rhs.element.name)
            if nameCmp != .orderedSame { return nameCmp == .orderedAscending }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func filter(_ repos: [AtlasCodeRepoRef], query: String) -> [AtlasCodeRepoRef] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return repos }
        return repos.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
                || ($0.folder?.localizedCaseInsensitiveContains(trimmed) ?? false)
        }
    }

    static func repos(
        from workspace: AtlasCodeWorkspaceResponse?,
        query: String
    ) -> [AtlasCodeRepoRef] {
        guard let ws = workspace else { return [] }
        let all = ws.folders.flatMap(\.repos) + ws.loose + ws.recents
        return filter(rank(all), query: query)
    }

    // MARK: Spoken

    static func spokenLoading() -> String { productLoadingCopy }

    static func spokenFailed() -> String { productFailedHeadline }

    static func spokenNoRepo() -> String { productNoRepo }

    static func spokenRow(folder: String?, name: String) -> String {
        if let folder, !folder.isEmpty {
            return "\(folder), \(name)"
        }
        return name
    }

    static func spokenRow(_ repo: AtlasCodeRepoRef) -> String {
        spokenRow(folder: repo.folder, name: repo.name)
    }

    static func spokenSheet(face: WorkspacePickerFace, title: String) -> String {
        "\(title), \(face.spokenFace)"
    }

    // MARK: Pack

    static func packFacts(
        phase: LoadPhase,
        repoCount: Int,
        query: String,
        showsNoRepo: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(phase: phase, repoCount: repoCount, query: query)
        facts.append("workspace_picker_face: \(face.productWord)")
        facts.append("workspace_picker_count: \(repoCount)")
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            facts.append("workspace_picker_query: \(trimmed)")
        }
        if showsNoRepo {
            facts.append("workspace_picker_no_repo_row: true")
        }
        switch face {
        case .loading:
            absences.append("repositórios ainda carregando do Mac")
        case .failed:
            absences.append("Mac não respondeu ao listar repositórios")
        case .empty:
            absences.append("nenhum repositório no workspace publicado")
        case .miss:
            absences.append("busca sem repositórios")
        case .list:
            break
        }
        return (facts, absences)
    }
}
// MARK: - Workspace / Search catalog judgment (WAVE-032)

/// Pure live-first ranking for thread catalogs — parity with LiveNow attention.
/// Prefer threadId identity; never invent live without signal.
enum WorkspaceThreadJudgment {
    static let productExecuting = "executando"

    // MARK: Row identity

    /// Segunda linha da conversa: o que o título gerado não diz.
    ///
    /// Títulos de máquina se repetem ponta a ponta e "2d" empata entre vários
    /// itens — o relógio é o único campo que separa dois testes do mesmo dia.
    /// - Parameter showsWorkspace: lista MISTA (busca, recentes). Aí o nome do
    ///   workspace entra no subtítulo — o trilho colorido agrupa, mas sozinho
    ///   ele é um código sem legenda: agrupa sem dizer O QUE agrupa. O operador
    ///   perguntou "não entendi essas cores" olhando exatamente esta lista.
    static func rowSubtitle(
        thread: AtlasAiThread,
        showsWorkspace: Bool = false,
        now: Date = Date()
    ) -> String {
        var parts: [String] = []
        if showsWorkspace, let ws = thread.workspace?.trimmingCharacters(in: .whitespaces),
           !ws.isEmpty {
            // O campo vem como path absoluto ("/private/tmp/atlas-p4-clone…/repo")
            // e sozinho comia a linha inteira, empurrando a hora para fora.
            // O nome final basta para ler; quando dois workspaces terminam
            // igual, o trilho colorido desambigua.
            parts.append((ws as NSString).lastPathComponent)
        }
        let summary = thread.summary?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !summary.isEmpty {
            parts.append(summary)
        } else {
            let count = thread.messageCount
            parts.append(count == 1 ? "1 mensagem" : "\(count) mensagens")
        }
        if let date = AtlasTime.date(thread.lastMessageAt ?? thread.updatedAt) {
            parts.append(date.formatted(date: .omitted, time: .shortened))
        }
        return parts.joined(separator: " · ")
    }

    /// Idade da última mensagem, curta. `nil` quando o servidor não datou.
    static func rowAge(thread: AtlasAiThread, now: Date = Date()) -> String? {
        guard let date = AtlasTime.date(thread.lastMessageAt ?? thread.updatedAt) else { return nil }
        return AtlasCodeRelativeTime.short(from: Int(date.timeIntervalSince1970), now: now)
    }

    // MARK: Running identity

    /// Thread ids with ongoing presence (local TurnPresence + remote hub).
    @MainActor
    static func liveThreadIDs(
        local: [LiveSessionSnapshot] = TurnPresence.shared.liveSessions,
        remote: [LiveSessionSnapshot] = []
    ) -> Set<String> {
        var ids = Set<String>()
        for session in local + remote {
            guard session.timing != .finished else { continue }
            if let tid = session.threadId?.rawValue, !tid.isEmpty {
                ids.insert(tid)
            }
        }
        return ids
    }

    /// Title fallback only when session has no threadId (local new conversation).
    @MainActor
    static func liveTitlesWithoutThreadID(
        local: [LiveSessionSnapshot] = TurnPresence.shared.liveSessions,
        remote: [LiveSessionSnapshot] = []
    ) -> Set<String> {
        var titles = Set<String>()
        for session in local + remote {
            guard session.timing != .finished else { continue }
            if session.threadId == nil {
                let t = session.title.trimmingCharacters(in: .whitespacesAndNewlines)
                if !t.isEmpty { titles.insert(t) }
            }
        }
        return titles
    }

    /// Honest running signal for a catalog row.
    @MainActor
    static func isRunning(
        threadID: String,
        title: String,
        liveIDs: Set<String>,
        liveTitlesFallback: Set<String>
    ) -> Bool {
        if liveIDs.contains(threadID) { return true }
        // Title fallback only when no threadId-bound live exists for this title collision path.
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && liveTitlesFallback.contains(trimmed)
    }

    @MainActor
    static func isRunning(
        thread: AtlasAiThread,
        remote: [LiveSessionSnapshot] = []
    ) -> Bool {
        let ids = liveThreadIDs(remote: remote)
        let titles = liveTitlesWithoutThreadID(remote: remote)
        return isRunning(threadID: thread.id, title: thread.title, liveIDs: ids, liveTitlesFallback: titles)
    }

    // MARK: Rank

    /// Live-first; stable secondary (input order). Empty live → unchanged order.
    @MainActor
    static func rank(
        _ threads: [AtlasAiThread],
        remote: [LiveSessionSnapshot] = []
    ) -> [AtlasAiThread] {
        let ids = liveThreadIDs(remote: remote)
        let titles = liveTitlesWithoutThreadID(remote: remote)
        guard !ids.isEmpty || !titles.isEmpty else { return threads }

        return threads.enumerated().sorted { lhs, rhs in
            let lLive = isRunning(
                threadID: lhs.element.id,
                title: lhs.element.title,
                liveIDs: ids,
                liveTitlesFallback: titles
            )
            let rLive = isRunning(
                threadID: rhs.element.id,
                title: rhs.element.title,
                liveIDs: ids,
                liveTitlesFallback: titles
            )
            if lLive != rLive { return lLive && !rLive }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    // MARK: Pack shell (WAVE-185)

    /// Workspace catalog shell — key · thread count · path honesty.
    static func packShellFacts(
        workspaceKey: String,
        displayName: String,
        threadCount: Int,
        fullPath: String?
    ) -> (facts: [String], absences: [String], anchors: [String]) {
        var facts: [String] = [
            "workspace_key: \(workspaceKey)",
            "workspace_thread_count: \(threadCount)",
        ]
        var absences: [String] = []
        let anchors: [String] = ["workspace: \(displayName)"]

        if let fullPath, !fullPath.isEmpty {
            facts.append("workspace_path: \(fullPath)")
        } else {
            absences.append("caminho completo do workspace não listado nas threads")
        }
        if threadCount == 0 {
            absences.append("ainda não há conversas neste workspace")
        }
        absences.append("não invente grafo/Arena/frota; pack é só deste workspace")
        return (facts, absences, anchors)
    }

    // MARK: Pack live scoped

    /// Live subjects scoped to a workspace path/key when published.
    @MainActor
    static func liveInWorkspaceFacts(
        workspaceKey: String?,
        sessionThreads: [AtlasAiThread],
        remote: [LiveSessionSnapshot] = []
    ) -> (facts: [String], absences: [String], subjects: [String]) {
        let ranked = rank(sessionThreads, remote: remote)
        let live = ranked.filter { isRunning(thread: $0, remote: remote) }
        var facts: [String] = []
        var absences: [String] = []
        if live.isEmpty {
            facts.append("live_neste_workspace: 0")
            absences.append("nenhuma sessão viva casada por threadId neste catálogo")
        } else {
            facts.append("live_neste_workspace: \(live.count)")
            for t in live.prefix(5) {
                facts.append("live_thread: \(t.title)")
            }
        }
        if workspaceKey != nil {
            facts.append("catalogo: workspace_scoped")
        }
        return (facts, absences, live.prefix(5).map(\.title))
    }

    // MARK: Catalog chrome spoken (IDLE · was RootChromeRowA11y)

    static let spokenProfile = "perfil do operador"
    static let spokenProfileHint = "abre seu perfil e o estado da sessão"

    static func workspaceSpoken(
        name: String,
        count: Int?,
        detail: String?,
        badge: Bool
    ) -> String {
        var parts = [name]
        if let count {
            parts.append(count == 0 ? "nenhuma conversa" : "\(count) conversa\(count == 1 ? "" : "s")")
        }
        if let detail, !detail.isEmpty {
            parts.append(detail)
        }
        if badge {
            parts.append("atenção necessária")
        }
        return parts.joined(separator: ", ")
    }

    static func threadSpoken(
        title: String,
        messageCount: Int,
        isRunning: Bool,
        isNew: Bool,
        hasWorkspace: Bool
    ) -> String {
        var parts = [title]
        if isRunning {
            parts.append("Atlas executando")
        } else if messageCount == 0 {
            parts.append("nenhuma mensagem")
        } else {
            parts.append("\(messageCount) mensagem\(messageCount == 1 ? "" : "ns")")
        }
        if isNew && !isRunning {
            parts.append("novo desde a última visita")
        }
        if hasWorkspace {
            parts.append("com workspace")
        }
        return parts.joined(separator: ", ")
    }

    static func spokenThreadHint(isRunning: Bool) -> String {
        isRunning ? "Atlas executando nesta conversa" : "abre a conversa"
    }
}
