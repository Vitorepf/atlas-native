import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: WorkspaceSurface + WorkspaceView entry fused

// MARK: - Surface

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

    var workspaceScreenHint: String {
        WorkspaceJudgment.screenHint(freeOnly: freeOnly)
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
            .accessibilityHint(workspaceScreenHint)
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
        .accessibilityLabel(WorkspaceJudgment.backLabel)
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
        .accessibilityHint(WorkspaceJudgment.areaFilterHint)
        .accessibilityAddTraits(active ? .isSelected : [])
    }
}

extension WorkspaceView {
    func areaFilterChipLabel(_ a: AtlasArea, active: Bool) -> some View {
        Text(a.label)
            .font(.system(.subheadline, weight: .medium))
            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textSecondary)
            .padding(.horizontal, 14).padding(.vertical, 7)
            .background(
                Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface)
                    .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
            )
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
        .accessibilityLabel(WorkspaceJudgment.newConversationLabel)
        .accessibilityHint(WorkspaceJudgment.newConversationHint)
        .accessibilityIdentifier(A11yID.workspaceNewPill)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    private var workspacePillInvite: String {
        if freeOnly {
            return WorkspaceAskContext.freeInvite
        }
        if let workspaceKey {
            return WorkspaceAskContext.invite(workspaceName: title.isEmpty ? workspaceKey : title)
        }
        return HomeAskContext.invite
    }
}

// MARK: - Body

// MARK: - Thread rows
extension WorkspaceThreadsSection {
    @ViewBuilder
    func threadRowLoop(_ t: AtlasAiThread, newBadgeSuppressed: Bool = false) -> some View {
        WorkspaceThreadLink(thread: t, reduceMotion: reduceMotion, newBadgeSuppressed: newBadgeSuppressed)
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
            .padding(.bottom, 96)
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
            retryHint: "reconecta e recarrega conversas deste workspace",
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
            WorkspaceLoadingEmpty(reduceMotion: reduceMotion)
                .accessibilityIdentifier(A11yID.workspaceLoading)
        } else if showsNetworkFailure {
            listNetworkFailure
        } else {
            listLoadedContent
        }
    }
}

// MARK: - Thread link
struct WorkspaceThreadLink: View {
    let thread: AtlasAiThread
    let reduceMotion: Bool
    var newBadgeSuppressed: Bool = false

    var body: some View {
        threadLinkA11y
    }
}

extension WorkspaceThreadLink {
    var threadLinkA11y: some View {
        NavigationLink(value: Route.thread(id: ThreadID(thread.id), title: thread.title)) {
            ThreadRow(thread: thread, newBadgeSuppressed: newBadgeSuppressed)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(SearchListJudgment.spokenRow(thread: thread))
        .accessibilityHint("abre a conversa")
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

// MARK: - Thread row

// MARK: - Row host

struct ThreadRow: View {
    let thread: AtlasAiThread
    var newBadgeSuppressed: Bool = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(AtlasSession.self) private var session

    /// WAVE-032: threadId-first running signal (title fallback only if no id).
    var isRunning: Bool {
        WorkspaceThreadJudgment.isRunning(
            thread: thread,
            remote: session.remoteLiveSessions
        )
    }
    var isNew: Bool { !newBadgeSuppressed && ConversationModel.hasNewerContent(thread) }
    var workspaceTint: Color? { thread.workspace.map(threadWorkspaceColor) }

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
            .accessibilityHint(WorkspaceThreadJudgment.threadHint(isRunning: isRunning))
    }

    var rowContent: some View {
        HStack(spacing: 14) {
            rowLead
            Text(thread.title).font(AtlasFont.serif(16)).foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1).truncationMode(.tail)
                .accessibilityHidden(true)
            Spacer(minLength: 8)
            rowTrailing
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .overlay(alignment: .leading) { rowWorkspaceTint }
        .contentShape(Rectangle())
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
            Rectangle()
                .fill(workspaceTint.opacity(0.85))
                .frame(width: 2)
                .padding(.vertical, 10)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    var rowTrailing: some View {
        newThreadBadge
        if isRunning {
            Text("executando").font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        } else {
            Text("\(thread.messageCount)")
                .atlasSans(16)
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
        Image(systemName: "chevron.right")
            .atlasSans(13, .semibold).foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    var newThreadBadge: some View {
        if isNew && !isRunning {
            Text("novo")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.accent)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Capsule().fill(AtlasTheme.goldVeil))
                .accessibilityHidden(true)
        }
    }
}

// MARK: - AtlasWorkspacePickerSheet

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
            .searchable(text: $query, prompt: WorkspacePickerJudgment.searchPrompt)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(WorkspacePickerJudgment.closeLabel) { dismiss() }
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
                Text(WorkspacePickerJudgment.loadingCopy)
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel(WorkspacePickerJudgment.spokenLoading())
        case .failed:
            VStack(spacing: 10) {
                Text(WorkspacePickerJudgment.failedHeadline)
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Button(WorkspacePickerJudgment.retryLabel) { Task { await model.load() } }
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
                    .atlasSans(16)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 22)
                VStack(alignment: .leading, spacing: 2) {
                    Text(WorkspacePickerJudgment.noRepoTitle).atlasSans(16, .medium)
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text(WorkspacePickerJudgment.noRepoSubtitle).atlasSans(13)
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                Spacer()
                Image(systemName: "chevron.right").atlasSans(13, .semibold)
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.horizontal, 14).padding(.vertical, 14)
            .contentShape(Rectangle())
            .atlasCard()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(WorkspacePickerJudgment.spokenNoRepo())
        .accessibilityHint(WorkspacePickerJudgment.noRepoHint)
        .accessibilityIdentifier(A11yID.workspacePickerNoRepo)
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 12)
    }

    var pickerRepoList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(WorkspacePickerJudgment.reposCaption)
                    .font(AtlasFont.mono(11, .medium)).tracking(1.6)
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
                    Text(age).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(WorkspacePickerJudgment.spokenRow(repo))
        .accessibilityHint(WorkspacePickerJudgment.rowHint)
        .accessibilityIdentifier(A11yID.workspacePickerRow(repo.slug))
    }
}
