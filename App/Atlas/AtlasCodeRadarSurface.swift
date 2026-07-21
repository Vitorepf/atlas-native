import SwiftUI
import AtlasCore

// WAVE-011 radar surface extensions

// MARK: - Repo row
extension AtlasCodeRepoRow {
    var repoRowButton: some View {
        Button(action: onTap) {
            repoRowLabel
        }
        .buttonStyle(.plain)
    }
}

extension AtlasCodeRepoRow {
    func repoRowSpokenBind<V: View>(_ button: V) -> some View {
        // children:.ignore cria um nó único (Other) com label/id — remover
        // isso derrubou o app no walk de a11y (SIGSEGV); o TESTE busca por
        // .any, não por .buttons. Não mexer sem bateria 3× verde.
        button
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                AtlasCodeRadarJudgment.spokenRepo(
                    name: repo.name,
                    folder: repo.folder,
                    showsFolder: showsFolder,
                    issues: issues,
                    trunk: trunk,
                    lastCommitAt: repo.lastCommitAt,
                    isMute: isMute
                )
            )
            .accessibilityHint(AtlasCodeRadarJudgment.repoHint)
            .accessibilityIdentifier(A11yID.radarRepo(repo.slug))
    }
}

extension AtlasCodeRepoRow {
    var repoRowA11yChrome: some View {
        repoRowSpokenBind(repoRowButton)
    }
}







// MARK: - Status capsule spoken
extension AtlasCodeRadarStatusCapsule {
    func spokenStatusQuiet(model: AtlasCodeWorkspaceModel) -> String? {
        switch model.scanState {
        case .clean:
            return "código quieto, nada pede você"
        case .unknown:
            return model.headline
        default:
            return nil
        }
    }
}

extension AtlasCodeRadarStatusCapsule {
    /// Frota quieta = caption mínima; alarme só com violação verificada no scan.
    func spokenStatus(model: AtlasCodeWorkspaceModel) -> String {
        spokenStatusQuiet(model: model) ?? "atenção, \(model.headline)"
    }
}

extension AtlasCodeRadarView {
    /// WAVE-067: exclusive radar screen face from published phase + repo count.
// MARK: - Radar screen face
    var radarScreenFace: AtlasCodeRadarScreenFace {
        let fail: String? = {
            if case .failed(let message) = model.phase { return message }
            return nil
        }()
        return AtlasCodeRadarLoadJudgment.face(
            phase: model.phase,
            repositoryCount: model.workspace?.repositoryCount,
            failMessage: fail
        )
    }

    var contentPhaseID: String {
        // idle maps to loading phaseID (honesty: not a distinct product face).
        if case .idle = model.phase { return "idle" }
        return radarScreenFace.phaseID
    }

    var radarShellSpokenLabel: String {
        AtlasCodeRadarLoadJudgment.spokenShell(face: radarScreenFace)
    }

    static var shellHint: String { AtlasCodeRadarLoadJudgment.shellHint }

    func spokenEmptyWorkspace() -> String {
        AtlasCodeRadarScreenFace.empty.spokenFace
    }

    func spokenLoading() -> String {
        AtlasCodeRadarScreenFace.loading.spokenFace
    }

    func spokenFailed(_ message: String) -> String {
        AtlasCodeRadarScreenFace.failed(
            message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil
                : message.trimmingCharacters(in: .whitespacesAndNewlines)
        ).spokenFace
    }
}

// MARK: - Radar content states
extension AtlasCodeRadarView {
    @ViewBuilder
    var radarContentBusy: some View {
        switch model.phase {
        case .idle, .loading:
            radarLoadingContent
        case .failed(let message):
            radarFailed(message)
        default:
            EmptyView()
        }
    }
}

extension AtlasCodeRadarView {
    var radarLoadingContent: some View {
        TraceEvidenceLoading(text: "lendo o seu workspace…", reduceMotion: reduceMotion)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier(A11yID.radarLoading)
    }
}

extension AtlasCodeRadarView {
    @ViewBuilder
    var radarContent: some View {
        switch model.phase {
        case .idle, .loading, .failed:
            radarContentBusy
        case .loaded:
            radarLoadedOrEmpty
        }
    }
}

extension AtlasCodeRadarView {
    @ViewBuilder
    var radarLoadedOrEmpty: some View {
        if let workspace = model.workspace {
            AtlasCodeRadarLoadedContent(workspace: workspace, model: model, onOpenRepo: onOpenRepo)
        } else {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel(spokenEmptyWorkspace())
        }
    }
}

extension AtlasCodeRadarView {
    @ViewBuilder
    func radarFailed(_ message: String) -> some View {
        AtlasCodeLoadFailureEmpty(
            headline: "não consegui ler o workspace",
            message: message.trimmingCharacters(in: .whitespacesAndNewlines),
            onRetry: { Task { await model.load() } }
        )
        .accessibilityLabel(spokenFailed(message))
        .accessibilityHint("reconecta ao servidor Atlas")
        .accessibilityIdentifier(A11yID.radarFailure)
    }
}

extension AtlasCodeRadarView {
    var radarContentShell: some View {
        // Fundo como .background: a barra nativa precisa enxergar o scroll
        // para ligar o scroll-edge material (ZStack escondia).
        radarNavShell(
            radarContent
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
                .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
                .padding(.bottom, 88)
        )
        .background(AtlasTheme.bg.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            askPillDock
        }
        .sheet(isPresented: $showingAsk) {
            askConversationSheet
        }
    }
}

extension AtlasCodeRadarView {
    @ViewBuilder
    func radarNavShell<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("Código")
            .navigationBarTitleDisplayMode(.inline)
            .task { if model.phase == .idle { await model.load() } }
            .refreshable { await model.load() }
            .accessibilityIdentifier(A11yID.radarScreen)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(radarShellSpokenLabel)
            .accessibilityValue(radarScreenFace.productWord)
            .accessibilityHint(Self.shellHint)
    }
}

struct AtlasCodeRadarView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var model: AtlasCodeWorkspaceModel
    let onOpenRepo: (String) -> Void
    /// Pílula = porta de intenção no Radar (WAVE-001 grafo soberano / julgamento).
    @State var showingAsk = false
    @State var askThreadId: ThreadID?
    @State var askDraft = ""

    var body: some View {
        radarContentShell
    }

    init(client: AtlasClient, onOpenRepo: @escaping (String) -> Void) {
        _model = State(initialValue: AtlasCodeWorkspaceModel(client: client))
        self.onOpenRepo = onOpenRepo
    }

}

// MARK: - AtlasCodeRadarView

// MARK: - Folder row peels

extension AtlasCodeFolderRow {
    var folderHeaderLeading: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder")
                .atlasSans(15)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 20)
                .accessibilityHidden(true)
            folderTitleStack
        }
    }
}

extension AtlasCodeFolderRow {
    var folderHeaderTrailing: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 6)
            exceptionBadge
            folderHeaderChevron
        }
    }
}

extension AtlasCodeFolderRow {
    var folderHeaderLabel: some View {
        HStack(spacing: 12) {
            folderHeaderLeading
            folderHeaderTrailing
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

extension AtlasCodeFolderRow {
    @ViewBuilder
    var folderHeaderChevron: some View {
        Image(systemName: "chevron.right")
            .atlasSans(12, .semibold)
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
            .rotationEffect(.degrees(isExpanded ? 90 : 0))
            .accessibilityHidden(true)
    }
}

extension AtlasCodeFolderRow {
    var folderTitleStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Mesma voz das linhas irmãs (repo=medium, pasta=semibold): serif
            // é masthead/título — linha de lista fala em sans (canon §C).
            Text(folder.name)
                .atlasSans(15, .semibold)
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(folder.repositories == 1 ? "1 repositório" : "\(folder.repositories) repositórios")
                .atlasSans(11.5)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .accessibilityHidden(true)
    }
}

extension AtlasCodeFolderRow {
    func folderToggleA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                AtlasCodeRadarJudgment.spokenFolder(
                    name: folder.name,
                    repositoryCount: folder.repositories,
                    verifiedExceptionCount: verifiedExceptionCount,
                    isExpanded: isExpanded
                )
            )
            .accessibilityHint(AtlasCodeRadarJudgment.spokenFolderHint(isExpanded: isExpanded))
            .accessibilityIdentifier(A11yID.radarFolder(folder.slug))
    }
}

// MARK: - Loaded content peels

extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarFoldersHeader: some View {
        if !workspace.folders.isEmpty {
            AtlasCodeRadarSectionLabel(text: "PASTAS", accessibilityID: A11yID.radarFolders)
                .padding(.top, 22)
        }
    }
}

extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarFoldersLoop: some View {
        if !workspace.folders.isEmpty {
            ForEach(workspace.folders) { folder in
                AtlasCodeFolderRow(
                    folder: folder,
                    isExpanded: model.expandedFolders.contains(folder.slug),
                    issuesFor: { model.issues(for: $0) },
                    trunkFor: { model.trunk(for: $0) },
                    isMuteFor: { model.failedSlugs.contains($0) },
                    onToggle: { Task { await model.toggle(folder) } },
                    onOpenRepo: onOpenRepo
                )
                if folder.id != workspace.folders.last?.id { AtlasCodeRadarRowDivider() }
            }
        }
    }
}

extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarFoldersAndLoose: some View {
        radarFoldersHeader
        radarFoldersLoop
        radarLooseSection
    }
}

extension AtlasCodeRadarLoadedContent {
    /// WAVE-024: issues-first judgment order when scan hydrated.
    var judgmentLoose: [AtlasCodeRepoRef] {
        AtlasCodeRadarJudgment.sortedForJudgment(
            workspace.loose,
            issuesBySlug: model.issuesBySlug,
            failedSlugs: model.failedSlugs
        )
    }

    @ViewBuilder
    var radarLooseSection: some View {
        if !workspace.loose.isEmpty {
            AtlasCodeRadarSectionLabel(text: "AVULSOS", accessibilityID: A11yID.radarLoose)
                .padding(.top, 22)
            ForEach(judgmentLoose) { repo in
                AtlasCodeRepoRow(
                    repo: repo,
                    issues: model.issues(for: repo.slug),
                    trunk: model.trunk(for: repo.slug),
                    showsFolder: false,
                    isMute: model.failedSlugs.contains(repo.slug)
                ) {
                    onOpenRepo(repo.slug)
                }
                if repo.id != judgmentLoose.last?.id { AtlasCodeRadarRowDivider() }
            }
        }
    }
}

extension AtlasCodeRadarLoadedContent {
    var judgmentRecents: [AtlasCodeRepoRef] {
        AtlasCodeRadarJudgment.sortedForJudgment(
            workspace.recents,
            issuesBySlug: model.issuesBySlug,
            failedSlugs: model.failedSlugs
        )
    }

    @ViewBuilder
    var radarRecentsSection: some View {
        if !workspace.recents.isEmpty {
            AtlasCodeRadarSectionLabel(text: "RECENTES", accessibilityID: A11yID.radarRecents)
            ForEach(judgmentRecents) { repo in
                AtlasCodeRepoRow(
                    repo: repo,
                    issues: model.issues(for: repo.slug),
                    trunk: model.trunk(for: repo.slug),
                    showsFolder: true,
                    isMute: model.failedSlugs.contains(repo.slug)
                ) {
                    onOpenRepo(repo.slug)
                }
                if repo.id != judgmentRecents.last?.id { AtlasCodeRadarRowDivider() }
            }
        }
    }
}

extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarSections: some View {
        AtlasCodeRadarStatusCapsule(model: model)
            .padding(.bottom, 18)

        radarRecentsSection

        radarFoldersAndLoose
    }
}

// MARK: - Loaded host

struct AtlasCodeRadarLoadedContent: View {
    let workspace: AtlasCodeWorkspaceResponse
    let model: AtlasCodeWorkspaceModel
    let onOpenRepo: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                radarSections
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
    }
}

// MARK: - AtlasCodeRadarAskContext

// MARK: - Invite · pack

enum AtlasCodeRadarAskContext {
    static let invite = "pergunte sobre o workspace"

    static var emptySuggestions: [String] {
        [
            "o que pede atenção no workspace?",
            "quais pastas têm sem retorno?",
            "por onde começar a curar?",
        ]
    }

    static func emptyPrompt(headline: String?) -> String {
        let line = headline?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !line.isEmpty, line != "lendo o workspace…" {
            return "workspace · \(line) — o que você quer saber?"
        }
        return invite
    }

    /// Pack da ocasião do radar — never invents scan results.
    @MainActor
    static func facts(model: AtlasCodeWorkspaceModel) -> String {
        var facts: [String] = []
        var absences: [String] = []
        var anchors: [String] = []

        // WAVE-183: catalog shell pack (folders/recents/root).
        let shellPack = AtlasCodeRadarJudgment.packWorkspaceFacts(
            workspace: model.workspace
        )
        facts.append(contentsOf: shellPack.facts)
        absences.append(contentsOf: shellPack.absences)
        anchors.append(contentsOf: shellPack.anchors)

        // WAVE-182: fleet attention pack (one law with topAttention rank).
        let attentionPack = AtlasCodeRadarJudgment.packFacts(
            issuesBySlug: model.issuesBySlug,
            failedSlugs: model.failedSlugs,
            headline: model.headline
        )
        facts.append(contentsOf: attentionPack.facts)
        absences.append(contentsOf: attentionPack.absences)
        anchors.append(contentsOf: attentionPack.anchors)

        // WAVE-162: radar screen face organ.
        let failMsg: String? = {
            if case .failed(let m) = model.phase { return m }
            return nil
        }()
        let repoCount = model.workspace.map { $0.folders.reduce(0) { $0 + $1.repos.count } + $0.recents.count }
        let screenPack = AtlasCodeRadarLoadJudgment.packFacts(
            phase: model.phase,
            repositoryCount: repoCount,
            failMessage: failMsg
        )
        facts.append(contentsOf: screenPack.facts)
        absences.append(contentsOf: screenPack.absences)

        // WAVE-158: can_do matrix — radar list has no local heal CTA; honesty via absences.
        let attentionCount = AtlasCodeRadarJudgment.topAttention(issuesBySlug: model.issuesBySlug).count
        let partida = PartidaCanDoJudgment.radar(
            hasHealFaceCTA: false,
            attentionCount: attentionCount
        )
        absences.append(contentsOf: partida.absences)

        return AgenticOccasionPack(
            surface: "code.radar",
            subject: "workspace do operador",
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: partida.canDo
        ).render()
    }
}

// MARK: - Folder row chrome

extension AtlasCodeFolderRow {
    @ViewBuilder
    var exceptionBadge: some View {
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
    }
}

extension AtlasCodeFolderRow {
    /// Só violações de repos já varridos — nil = ainda não medido, nunca conta.
    var verifiedExceptionCount: Int {
        folder.repos.reduce(0) { total, repo in
            guard let issues = issuesFor(repo.slug), !issues.isEmpty else { return total }
            return total + issues.reduce(0) { $0 + $1.count }
        }
    }
}

extension AtlasCodeFolderRow {
    @ViewBuilder var expandedRepos: some View {
        if isExpanded {
            expandedReposList
        }
    }
}

extension AtlasCodeFolderRow {
    /// WAVE-024: issues-first inside folder when scan data present via issuesFor.
    var judgmentFolderRepos: [AtlasCodeRepoRef] {
        let issuesMap = Dictionary(uniqueKeysWithValues: folder.repos.compactMap { repo -> (String, [AtlasCodeIssue])? in
            guard let issues = issuesFor(repo.slug) else { return nil }
            return (repo.slug, issues)
        })
        let failed = Set(folder.repos.map(\.slug).filter { isMuteFor($0) })
        return AtlasCodeRadarJudgment.sortedForJudgment(
            folder.repos,
            issuesBySlug: issuesMap,
            failedSlugs: failed
        )
    }

    var expandedReposList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(judgmentFolderRepos) { repo in
                AtlasCodeRepoRow(
                    repo: repo,
                    issues: issuesFor(repo.slug),
                    trunk: trunkFor(repo.slug),
                    showsFolder: false,
                    isMute: isMuteFor(repo.slug)
                ) {
                    onOpenRepo(repo.slug)
                }
                .padding(.leading, 32)
                expandedRepoSeparator(after: repo, in: judgmentFolderRepos)
            }
        }
        .padding(.bottom, 6)
        .transition(reduceMotion ? .identity : .opacity)
    }
}

extension AtlasCodeFolderRow {
    @ViewBuilder
    func expandedRepoSeparator(after repo: AtlasCodeRepoRef, in ordered: [AtlasCodeRepoRef]) -> some View {
        if repo.id != ordered.last?.id {
            Rectangle()
                .fill(AtlasTheme.separator.opacity(0.4))
                .frame(height: 0.5)
                .padding(.leading, 32)
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeFolderRow {
    var folderToggleButton: some View {
        folderToggleA11y(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onToggle()
            } label: {
                folderHeaderLabel
            }
            .buttonStyle(.plain)
        )
    }
}

// MARK: - AtlasCodeRadarJudgment

enum AtlasCodeRadarJudgment {
    // MARK: - Rank

    /// Issues-first when scan data exists; otherwise wire order (honesty).
    static func sortedForJudgment(
        _ repos: [AtlasCodeRepoRef],
        issuesBySlug: [String: [AtlasCodeIssue]],
        failedSlugs: Set<String>
    ) -> [AtlasCodeRepoRef] {
        guard !issuesBySlug.isEmpty || !failedSlugs.isEmpty else { return repos }

        func issueCount(_ slug: String) -> Int {
            issuesBySlug[slug]?.count ?? 0
        }

        func hasIssues(_ slug: String) -> Bool {
            guard let issues = issuesBySlug[slug] else { return false }
            return !issues.isEmpty
        }

        return repos.enumerated().sorted { lhs, rhs in
            let l = lhs.element.slug
            let r = rhs.element.slug
            let lIssues = hasIssues(l)
            let rIssues = hasIssues(r)
            if lIssues != rIssues { return lIssues && !rIssues }
            let lc = issueCount(l)
            let rc = issueCount(r)
            if lc != rc { return lc > rc }
            // Mute never ranks as clean priority — after issues, stable wire index.
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func issueSignalCount(_ issues: [AtlasCodeIssue]?) -> Int {
        issues?.count ?? 0
    }

    /// Top attention subjects for pack — real counts only.
    static func topAttention(
        issuesBySlug: [String: [AtlasCodeIssue]],
        limit: Int = 5
    ) -> [(slug: String, count: Int)] {
        issuesBySlug
            .compactMap { slug, issues -> (String, Int)? in
                guard !issues.isEmpty else { return nil }
                return (slug, issues.count)
            }
            .sorted { lhs, rhs in
                if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
                return lhs.0 < rhs.0
            }
            .prefix(limit)
            .map { (slug: $0.0, count: $0.1) }
    }

    // MARK: Pack workspace shell (WAVE-183)

    /// Catalog shell for Radar ask — folders/recents/root honesty only.
    // MARK: - Pack

    static func packWorkspaceFacts(
        workspace: AtlasCodeWorkspaceResponse?
    ) -> (facts: [String], absences: [String], anchors: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        var anchors: [String] = []
        guard let workspace else {
            facts.append("radar_workspace: not_loaded")
            absences.append("workspace wire nil até load")
            return (facts, absences, anchors)
        }
        facts.append("radar_folders: \(workspace.folders.count)")
        facts.append("radar_recents: \(workspace.recents.count)")
        if let root = workspace.workspaceRoot, !root.isEmpty {
            facts.append("radar_workspace_root: \(root)")
            anchors.append("root: \(root)")
        } else if let slug = workspace.recents.first?.slug {
            facts.append("radar_workspace_wire_fallback: \(slug) (primeiro recente)")
        } else {
            absences.append("sem workspace_root nem recentes para o wire")
        }
        return (facts, absences, anchors)
    }

    // MARK: Pack attention (WAVE-182)

    /// Fleet attention pack — never invents scan totals.
    static func packFacts(
        issuesBySlug: [String: [AtlasCodeIssue]],
        failedSlugs: Set<String> = [],
        headline: String? = nil,
        attentionLimit: Int = 5
    ) -> (facts: [String], absences: [String], anchors: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        var anchors: [String] = []

        let scanned = issuesBySlug.count
        let withIssues = issuesBySlug.values.filter { !$0.isEmpty }.count
        let totalIssues = issuesBySlug.values.reduce(0) { $0 + $1.count }

        if scanned > 0 {
            facts.append("radar_repos_scanned: \(scanned)")
            facts.append("radar_repos_with_sem_retorno: \(withIssues)")
            if totalIssues > 0 {
                facts.append("radar_sem_retorno_signals: \(totalIssues)")
            }
            if let headline, !headline.isEmpty {
                facts.append("radar_headline: \(headline)")
                anchors.append("headline: \(headline)")
            }
        } else {
            absences.append("nenhum scan de violações hidratado ainda")
        }

        if !failedSlugs.isEmpty {
            facts.append("radar_repos_mute: \(failedSlugs.sorted().joined(separator: ", "))")
        }

        let top = topAttention(issuesBySlug: issuesBySlug, limit: attentionLimit)
        if !top.isEmpty {
            for item in top {
                facts.append("radar_top: \(item.slug) · \(item.count)")
                anchors.append("attention · \(item.slug) · \(item.count)")
            }
        } else if scanned > 0 {
            absences.append("nenhum subject com sem-retorno no scan atual (frota quieta neste load)")
        }

        absences.append("não inventar merges ou cures; julgamento soberano do workspace")
        return (facts, absences, anchors)
    }

    static let muteBadgeLabel = "mudo"
    static let muteSpoken = "não respondeu ao scan"
    static let repoHint = "abre o grafo do repositório"

    // MARK: Folder / row spoken (IDLE · was AtlasCodeRadarA11y)

    // MARK: - Spoken

    static func spokenFolder(
        name: String,
        repositoryCount: Int,
        verifiedExceptionCount: Int,
        isExpanded: Bool
    ) -> String {
        var parts = [name, spokenRepoCount(repositoryCount)]
        if let phrase = exceptionPhrase(verifiedExceptionCount) {
            parts.append(phrase)
        }
        if isExpanded { parts.append("expandida") }
        return parts.joined(separator: ", ")
    }

    static func exceptionPhrase(_ verifiedExceptionCount: Int) -> String? {
        guard verifiedExceptionCount > 0 else { return nil }
        return "\(verifiedExceptionCount) sem retorno\(verifiedExceptionCount == 1 ? "" : "s") verificado\(verifiedExceptionCount == 1 ? "" : "s")"
    }

    static func spokenFolderHint(isExpanded: Bool) -> String {
        isExpanded ? "recolhe a pasta" : "expande a pasta"
    }

    static func spokenRepoCount(_ repositoryCount: Int) -> String {
        repositoryCount == 1 ? "1 repositório" : "\(repositoryCount) repositórios"
    }

    static func spokenRepoCommitAge(lastCommitAt: Int?) -> String? {
        guard let age = AtlasCodeAge.short(from: lastCommitAt) else { return nil }
        return "último commit \(age)"
    }

    static func spokenRepoFolder(folder: String?, showsFolder: Bool) -> [String] {
        guard showsFolder, let folder, !folder.isEmpty else { return [] }
        return ["pasta \(folder)"]
    }

    static func spokenRepo(
        name: String,
        folder: String?,
        showsFolder: Bool,
        issues: [AtlasCodeIssue]?,
        trunk: String?,
        lastCommitAt: Int?,
        isMute: Bool = false
    ) -> String {
        var parts = [name]
        parts.append(contentsOf: spokenRepoFolder(folder: folder, showsFolder: showsFolder))
        if isMute {
            parts.append(muteSpoken)
        } else {
            parts.append(contentsOf: spokenRepoIssues(issues: issues, trunk: trunk))
        }
        if let age = spokenRepoCommitAge(lastCommitAt: lastCommitAt) {
            parts.append(age)
        }
        return parts.joined(separator: ", ")
    }

    static func spokenRepoIssues(
        issues: [AtlasCodeIssue]?,
        trunk: String?
    ) -> [String] {
        guard let issues, !issues.isEmpty else { return [] }
        var parts: [String] = []
        if let first = issues.first {
            parts.append(first.headline(trunk: trunk))
            if first.isSevere { parts.append("alta severidade") }
        }
        if issues.count > 1 {
            let more = issues.count - 1
            parts.append("mais \(more) sem retorno\(more == 1 ? "" : "s")")
        }
        return parts
    }
}

// MARK: - AtlasCodeRadarRepoChrome

// MARK: - AtlasCodeRadarRepoChrome

struct AtlasCodeRepoRow: View {
    let repo: AtlasCodeRepoRef
    let issues: [AtlasCodeIssue]?
    /// A trunk real deste repo: a frase da issue fala o nome da linha.
    var trunk: String? = nil
    /// Nos recentes a pasta situa; dentro da pasta seria redundante.
    let showsFolder: Bool
    /// WAVE-024: scan failed / mute — never read as limpo.
    var isMute: Bool = false
    let onTap: () -> Void

    var body: some View {
        repoRowA11yChrome
    }
}

extension AtlasCodeRadarStatusCapsule {
    var alarmCapsule: some View {
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

extension AtlasCodeRadarStatusCapsule {
    /// Caption baixa — mesmo padrão da frota («frota» / «fila») sem incidente.
    var silentCaption: some View {
        Text(model.scanState == .clean ? "código" : model.headline)
            .atlasSans(11, .semibold)
            .tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.vertical, 7)
            .accessibilityHidden(true)
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

extension AtlasCodeRadarStatusCapsule {
    @ViewBuilder
    var statusSwitchBody: some View {
        Group {
            switch model.scanState {
            case .clean, .unknown:
                silentCaption
            case .violating:
                alarmCapsule
            }
        }
    }
}

// MARK: - Chrome do AtlasCodeRadarView (peel de AtlasCodeRadarSections)
// Capsules → +Capsules · Labels → +Labels

struct AtlasCodeRadarStatusCapsule: View {
    let model: AtlasCodeWorkspaceModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        // Silêncio = produto: saudável (sem violações) → caption quieta, sem
        // chrome de alarme/afirmação verde. Barulho só com exceção real.
        statusSwitchBody
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: model.scanState)
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityLabel(spokenStatus(model: model))
        .accessibilityIdentifier(A11yID.radarStatus)
    }
}

extension AtlasCodeRadarView {
    var askPillDock: some View {
        AgenticAskDock {
            AgenticPill(
                invite: AtlasCodeRadarAskContext.invite,
                accessibilityId: A11yID.radarAskPill,
                accessibilityHintText: "Abre conversa com o contexto do workspace"
            ) {
                askDraft = ""
                showingAsk = true
            }
        }
    }

    var askConversationSheet: some View {
        ConversationView(
            client: session.client,
            threadId: askThreadId,
            title: "Código · workspace",
            emptyPrompt: AtlasCodeRadarAskContext.emptyPrompt(headline: model.headline),
            emptySuggestions: AtlasCodeRadarAskContext.emptySuggestions,
            taskKind: "code",
            // Prefer root; senão primeiro recente; nil + absence no pack se vazio.
            workspace: radarWireWorkspace,
            draft: askDraft,
            turnFacts: { [model] _ in
                AtlasCodeRadarAskContext.facts(model: model)
            },
            onThread: { askThreadId = $0 },
            hidesNavigationBack: true
        )
        .agenticAskSheetPresentation()
    }

    /// Wire workspace honesto — só o que o model já expõe (WAVE-002).
    var radarWireWorkspace: String? {
        if let root = model.workspace?.workspaceRoot?.trimmingCharacters(in: .whitespacesAndNewlines),
           !root.isEmpty {
            return root
        }
        if let slug = model.workspace?.recents.first?.slug, !slug.isEmpty {
            return slug
        }
        return nil
    }
}
// MARK: - AtlasCodeRadarFolderRow

struct AtlasCodeFolderRow: View {
    let folder: AtlasCodeFolder
    let isExpanded: Bool
    let issuesFor: (String) -> [AtlasCodeIssue]?
    let trunkFor: (String) -> String?
    var isMuteFor: (String) -> Bool = { _ in false }
    let onToggle: () -> Void
    let onOpenRepo: (String) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            folderToggleButton
            expandedRepos
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: isExpanded)
    }
}

extension AtlasCodeRepoRow {
    var repoRowLabel: some View {
        HStack(alignment: .center, spacing: 12) {
            repoRowLeading
            Spacer(minLength: 6)
            repoRowTrailing
        }
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}

extension AtlasCodeRepoRow {
    var repoRowLeading: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 7) {
                Text(repo.name)
                    .atlasSans(15, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                repoFolderBadge
            }
            repoRowIssues
        }
        .accessibilityHidden(true)
    }
}

extension AtlasCodeRepoRow {
    @ViewBuilder
    var repoFolderBadge: some View {
        if showsFolder, let folder = repo.folder {
            Text(folder)
                .atlasSans(10)
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, 1.5)
                .background(Capsule().fill(AtlasTheme.surface))
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeRepoRow {
    @ViewBuilder
    var repoRowIssues: some View {
        if isMute {
            // WAVE-024: mute never reads as clean.
            HStack(spacing: 6) {
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .atlasSans(9, .semibold)
                    .accessibilityHidden(true)
                Text("\(AtlasCodeRadarJudgment.muteBadgeLabel) · \(AtlasCodeRadarJudgment.muteSpoken)")
                    .atlasSans(12)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
        } else if let issues, let first = issues.first {
            HStack(spacing: 6) {
                Circle()
                    .fill(first.isSevere ? AtlasCodePalette.alert : AtlasCodePalette.alert.opacity(0.45))
                    .frame(width: 4.5, height: 4.5)
                    .accessibilityHidden(true)
                Text(issues.count == 1 ? first.headline(trunk: trunk) : "\(first.headline(trunk: trunk)) · mais \(issues.count - 1) alerta\(issues.count - 1 == 1 ? "" : "s")")
                    .atlasSans(12)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension AtlasCodeRepoRow {
    @ViewBuilder
    var repoRowTrailing: some View {
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
}
// MARK: - AtlasCodeRadarLoadJudgment

// MARK: - Types

/// Exclusive multi-repo Radar screen face (WAVE-067).
enum AtlasCodeRadarScreenFace: Equatable {
    case loading
    case failed(String?)
    case empty
    case ready(Int)

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .ready: return "ready"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading:
            return "lendo o workspace"
        case .failed(let message):
            if let message, !message.isEmpty {
                return "workspace indisponível, \(message)"
            }
            return "workspace indisponível"
        case .empty:
            return "nenhum repositório neste workspace"
        case .ready(let n):
            return n == 1 ? "1 repositório" : "\(n) repositórios"
        }
    }

    var phaseID: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "loaded-empty"
        case .ready(let n): return "loaded-\(n)"
        }
    }
}

// MARK: - Judgment

/// Pure Radar screen load grammar — face · spoken · phaseID · pack.
enum AtlasCodeRadarLoadJudgment {

    static let shellHint = "pastas, recentes e sem retorno verificados do seu código"

    static func face(
        phase: LoadPhase,
        repositoryCount: Int?,
        failMessage: String? = nil
    ) -> AtlasCodeRadarScreenFace {
        switch phase {
        case .idle, .loading:
            return .loading
        case .failed(let message):
            let published = failMessage ?? message
            return .failed(published.isEmpty ? nil : published)
        case .loaded:
            let n = repositoryCount ?? 0
            if n <= 0 { return .empty }
            return .ready(n)
        }
    }

    static func spokenShell(face: AtlasCodeRadarScreenFace) -> String {
        "Código, workspace do operador, \(face.spokenFace)"
    }

    static func spokenShell(
        phase: LoadPhase,
        repositoryCount: Int?,
        failMessage: String? = nil
    ) -> String {
        spokenShell(
            face: face(
                phase: phase,
                repositoryCount: repositoryCount,
                failMessage: failMessage
            )
        )
    }

    static func packFacts(
        phase: LoadPhase,
        repositoryCount: Int?,
        failMessage: String? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(
            phase: phase,
            repositoryCount: repositoryCount,
            failMessage: failMessage
        )
        facts.append("radar_screen_face: \(face.productWord)")
        switch face {
        case .loading:
            absences.append("workspace radar ainda carregando")
        case .failed(let msg):
            absences.append("workspace radar falhou")
            if let msg, !msg.isEmpty { facts.append("radar_error: \(msg)") }
        case .empty:
            absences.append("workspace sem repositórios")
            facts.append("radar_repos: 0")
        case .ready(let n):
            facts.append("radar_repos: \(n)")
        }
        return (facts, absences)
    }
}

// MARK: - AtlasCodeHealVetoJudgment

// MARK: - Types

/// Exclusive heal veto face for Código receipt (WAVE-048).
enum AtlasCodeHealVetoFace: Equatable {
    case absent
    case completed
    case blocked(String)
    case vetoOpen
    case vetoClosed
    case undoFailed(String)

    var productWord: String {
        switch self {
        case .absent: return "absent"
        case .completed: return "completed"
        case .blocked: return "blocked"
        case .vetoOpen: return "veto_open"
        case .vetoClosed: return "veto_closed"
        case .undoFailed: return "undo_failed"
        }
    }

    var kicker: String {
        switch self {
        case .absent: return "Cura"
        case .completed: return "Curado sozinho"
        case .blocked: return "Cura bloqueada"
        case .vetoOpen: return "Veto aberto"
        case .vetoClosed: return "Veto encerrado"
        case .undoFailed: return "Veto falhou"
        }
    }

    var spokenFace: String {
        switch self {
        case .absent:
            return "sem recibo de cura"
        case .completed:
            return "curado sozinho, sem janela de veto ativa"
        case .blocked(let reason):
            return "cura bloqueada, \(reason)"
        case .vetoOpen:
            return "janela de veto aberta, desfazer com recibo disponível"
        case .vetoClosed:
            return "janela de veto encerrada"
        case .undoFailed(let message):
            return "falha ao desfazer, \(message)"
        }
    }
}

// MARK: - Judgment

/// Pure heal veto grammar — face · canVeto · pack · spoken.
enum AtlasCodeHealVetoJudgment {

    static func completedStepCount(_ heal: AtlasCodeHealResponse) -> Int {
        heal.stepReceipts.filter { $0.status == "completed" }.count
    }

    static func undoExpiresAt(_ heal: AtlasCodeHealResponse) -> String? {
        heal.stepReceipts.compactMap(\.undoExpiresAt).first
    }

    static func canVeto(_ heal: AtlasCodeHealResponse) -> Bool {
        heal.healId != nil && AtlasCodeUndoWindow.isOpen(expiresAt: undoExpiresAt(heal))
    }

    static func face(
        heal: AtlasCodeHealResponse?,
        undoError: String?
    ) -> AtlasCodeHealVetoFace {
        if let err = undoError?.trimmingCharacters(in: .whitespacesAndNewlines), !err.isEmpty {
            return .undoFailed(err)
        }
        guard let heal else { return .absent }
        if let blocked = heal.blocked, !blocked.isEmpty {
            return .blocked(blocked)
        }
        if canVeto(heal) {
            return .vetoOpen
        }
        if completedStepCount(heal) > 0 {
            // Completed but window closed or no healId for undo.
            if heal.healId != nil {
                return .vetoClosed
            }
            return .completed
        }
        return .completed
    }

    static func packFacts(
        heal: AtlasCodeHealResponse?,
        undoError: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(heal: heal, undoError: undoError)
        facts.append("heal_veto_face: \(face.productWord)")
        guard let heal else {
            absences.append("recibo de cura não hidratado neste recorte")
            return (facts, absences)
        }
        facts.append("heal_mode: \(heal.mode)")
        facts.append("heal_steps: \(heal.stepReceipts.count)")
        facts.append("heal_completed_steps: \(completedStepCount(heal))")
        facts.append("can_veto: \(canVeto(heal))")
        if let note = AtlasCodeUndoWindow.note(expiresAt: undoExpiresAt(heal)) {
            facts.append("veto_window: \(note)")
        } else {
            absences.append("janela de veto sem nota publicada")
        }
        if let err = undoError, !err.isEmpty {
            facts.append("undo_error: \(err)")
        } else {
            absences.append("nenhuma falha de veto neste recorte")
        }
        if heal.healId == nil {
            absences.append("heal_id ausente — veto indisponível")
        }
        return (facts, absences)
    }

    static func spokenUndoError(_ err: String) -> String {
        "falha ao desfazer, \(err)"
    }

    static let curedAloneOpenReceiptLabel = "curado sozinho, ver recibo de cura"

    static func spokenSheet(
        heal: AtlasCodeHealResponse,
        undoError: String?
    ) -> String {
        var parts = ["recibo de cura", heal.mode]
        let face = face(heal: heal, undoError: undoError)
        parts.append(face.spokenFace)
        if heal.stepReceipts.isEmpty {
            parts.append("sem passos no recibo")
        } else {
            let done = completedStepCount(heal)
            parts.append("\(heal.stepReceipts.count) passos, \(done) concluídos")
        }
        return parts.joined(separator: ", ")
    }
}

// MARK: - AtlasCodeAskPillJudgment

// MARK: - Types

/// Exclusive código ask-pill face (WAVE-062).
enum AtlasCodeAskPillFace: Equatable {
    case invite
    case anchoring
    case legend

    var productWord: String {
        switch self {
        case .invite: return "invite"
        case .anchoring: return "anchoring"
        case .legend: return "legend"
        }
    }

    var spokenFace: String {
        switch self {
        case .invite:
            return "convidar conversa sobre o repositório"
        case .anchoring:
            return "grafo recortado nos commits da resposta"
        case .legend:
            return "recortado com legenda de âncora"
        }
    }
}

// MARK: - Judgment

/// Pure ask-pill grammar — face · spoken · phaseID · pack.
enum AtlasCodeAskPillJudgment {

    static let spokenPillHint = "abre conversa sobre este repositório"
    static let spokenClear = "mostrar tudo no grafo"
    static let spokenClearHint = "remove o recorte dos commits da resposta"
    static let spokenClearCommitRef = "Limpar referência do commit"
    static let spokenAskCommit = "perguntar ao Atlas sobre este commit"
    static func spokenUserQuote(_ quote: String) -> String {
        "sua frase: \(quote)"
    }

    static func face(
        isAnchoring: Bool,
        anchorLegend: String?
    ) -> AtlasCodeAskPillFace {
        guard isAnchoring else { return .invite }
        let legend = anchorLegend?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !legend.isEmpty { return .legend }
        return .anchoring
    }

    static func spokenPill(
        isAnchoring: Bool,
        anchorLegend: String?
    ) -> String {
        let face = face(isAnchoring: isAnchoring, anchorLegend: anchorLegend)
        switch face {
        case .invite:
            return "Conversar com o Atlas sobre este repositório"
        case .anchoring:
            return "Conversar com o Atlas, grafo recortado nos commits da resposta"
        case .legend:
            let legend = anchorLegend?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return "Conversar com o Atlas, \(legend)"
        }
    }

    /// Animation / phase token (stable for reduceMotion gate).
    static func phaseID(
        isAnchoring: Bool,
        anchorLegend: String?
    ) -> String {
        let face = face(isAnchoring: isAnchoring, anchorLegend: anchorLegend)
        switch face {
        case .invite:
            return "invite"
        case .anchoring:
            return "anchoring-default"
        case .legend:
            return "anchoring-\(anchorLegend ?? "default")"
        }
    }

    static func packFacts(
        isAnchoring: Bool,
        anchorLegend: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(isAnchoring: isAnchoring, anchorLegend: anchorLegend)
        facts.append("ask_pill_face: \(face.productWord)")
        switch face {
        case .invite:
            absences.append("pílula em convite (sem âncora)")
        case .anchoring:
            facts.append("ask_pill_anchoring: true")
            absences.append("âncora sem legenda textual neste recorte")
        case .legend:
            facts.append("ask_pill_anchoring: true")
            if let legend = anchorLegend?.trimmingCharacters(in: .whitespacesAndNewlines),
               !legend.isEmpty {
                facts.append("ask_pill_legend: \(legend)")
            }
        }
        return (facts, absences)
    }
}

// MARK: - AtlasCodeRepoHealthJudgment

// MARK: - Judgment

// MARK: - Types

/// Exclusive single-repo health face (WAVE-043).
enum AtlasCodeRepoHealthFace: Equatable {
    case unbound
    case unknown
    case clean
    case healed
    case weekActive(commits: Int, heals: Int, prevented: Int)
    case violating(Int)
    case mirrorBlocked(rules: [String])

    var productWord: String {
        switch self {
        case .unbound: return "unbound"
        case .unknown: return "unknown"
        case .clean: return "clean"
        case .healed: return "healed"
        case .weekActive: return "week_active"
        case .violating: return "violating"
        case .mirrorBlocked: return "mirror_blocked"
        }
    }

    var kicker: String {
        switch self {
        case .unbound: return "Repo"
        case .unknown: return "Varredura desconhecida"
        case .clean: return "Linha quieta"
        case .healed: return "Curado sozinho"
        case .weekActive: return "Semana ativa"
        case .violating: return "Sem retorno"
        case .mirrorBlocked: return "Espelho bloqueado"
        }
    }

    var spokenFace: String {
        switch self {
        case .unbound:
            return "repositório ainda não carregado"
        case .unknown:
            return "varredura ainda não conhecida"
        case .clean:
            return "linha principal quieta, sem sem-retorno"
        case .healed:
            return "linha quieta e curada sozinha"
        case .weekActive(let commits, let heals, let prevented):
            var parts = ["semana ativa"]
            if commits > 0 {
                parts.append(commits == 1 ? "1 commit" : "\(commits) commits")
            }
            if heals > 0 {
                parts.append(heals == 1 ? "1 cura" : "\(heals) curas")
            }
            if prevented > 0 {
                parts.append(prevented == 1 ? "1 prevenida" : "\(prevented) prevenidas")
            }
            return parts.joined(separator: ", ")
        case .violating(let n):
            return n == 1 ? "1 sem retorno" : "\(n) sem retorno"
        case .mirrorBlocked(let rules):
            if rules.isEmpty {
                return "espelho bloqueado, segredo detectado"
            }
            return "espelho bloqueado, regras \(rules.joined(separator: ", "))"
        }
    }
}

// MARK: - Judgment

/// Pure repo health grammar — face · summary · pack · spoken.
/// Attention lead: mirror blocked → violating → healed → week active → clean.
enum AtlasCodeRepoHealthJudgment {

    // MARK: Face

    @MainActor
    static func face(
        model: AtlasCodeModel,
        mirror: AtlasCodeMirrorResponse? = nil
    ) -> AtlasCodeRepoHealthFace {
        switch model.phase {
        case .idle, .loading:
            return .unbound
        case .failed:
            return .unknown
        case .loaded:
            break
        }

        if let mirror, case .blocked(let rules) = mirror.state {
            return .mirrorBlocked(rules: rules)
        }

        switch model.scanState {
        case .violating:
            let n = model.violations?.violations.count ?? 0
            return .violating(max(n, 1))
        case .unknown:
            return .unknown
        case .clean:
            break
        }

        if model.hasHealReceipt {
            return .healed
        }

        if let week = model.week, !AtlasCodeWeekUI.isQuiet(week) {
            return .weekActive(
                commits: week.commits,
                heals: week.heals,
                prevented: week.prevented
            )
        }

        return .clean
    }

    // MARK: Summary

    @MainActor
    static func summaryLine(
        model: AtlasCodeModel,
        mirror: AtlasCodeMirrorResponse? = nil
    ) -> String {
        let face = face(model: model, mirror: mirror)
        var parts: [String] = [face.kicker]

        // Always honest secondary signals when present (not invent).
        if model.hasViolations {
            let n = model.violations?.violations.count ?? 0
            if n > 0 { parts.append(n == 1 ? "1 sem retorno" : "\(n) sem retorno") }
        }
        if model.hasHealReceipt {
            parts.append("cura publicada")
        }
        if let week = model.week {
            if AtlasCodeWeekUI.isQuiet(week) {
                parts.append("semana quieta")
            } else {
                if week.commits > 0 { parts.append("\(week.commits) commits") }
                if week.heals > 0 { parts.append("\(week.heals) curas") }
                if week.prevented > 0 { parts.append("\(week.prevented) prevenidas") }
            }
        }
        if let mirror {
            switch mirror.state {
            case .blocked:
                parts.append("espelho bloqueado")
            case .pending(let n):
                parts.append(n == 1 ? "1 commit só no Mac" : "\(n) commits só no Mac")
            case .mirrored:
                parts.append("espelho ok")
            case .noMirror, .unknown:
                break
            }
        }

        // De-dupe adjacent identical kickers.
        var out: [String] = []
        for p in parts where out.last != p {
            out.append(p)
        }
        return out.joined(separator: " · ")
    }

    // MARK: Pack

    @MainActor
    static func packFacts(
        model: AtlasCodeModel,
        mirror: AtlasCodeMirrorResponse? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(model: model, mirror: mirror)
        facts.append("repo_health_face: \(face.productWord)")
        facts.append(summaryLine(model: model, mirror: mirror))

        switch model.phase {
        case .idle, .loading:
            absences.append("grafo ainda não carregado — não invente saúde")
            return (facts, absences)
        case .failed:
            absences.append("load do grafo falhou — saúde desconhecida")
            return (facts, absences)
        case .loaded:
            break
        }

        facts.append("scan: \(AtlasCodeGraphJudgment.scanWord(model.scanState))")
        facts.append("status_headline: \(model.statusHeadline)")

        if model.violations == nil {
            absences.append("violações não hidratadas neste load")
        } else if !model.hasViolations {
            facts.append("violations: 0")
        } else {
            facts.append("violations: \(model.violations?.violations.count ?? 0)")
        }

        if model.hasHealReceipt {
            facts.append("heal_receipt: present")
        } else {
            absences.append("sem recibo de cura neste recorte")
        }

        if let week = model.week {
            facts.append("week_window: \(week.window)")
            facts.append("week_commits: \(week.commits)")
            facts.append("week_heals: \(week.heals)")
            facts.append("week_prevented: \(week.prevented)")
        } else {
            absences.append("semana (week) não hidratada")
        }

        if let mirror {
            facts.append("mirror_state: \(mirrorStateWord(mirror.state))")
            if case .blocked(let rules) = mirror.state, !rules.isEmpty {
                facts.append("mirror_blocked_rules: \(rules.joined(separator: ","))")
            }
        } else {
            absences.append("espelho não hidratado neste recorte")
        }

        return (facts, absences)
    }

    static func mirrorStateWord(_ state: AtlasCodeMirrorResponse.State) -> String {
        switch state {
        case .blocked: return "blocked"
        case .mirrored: return "mirrored"
        case .pending: return "pending"
        case .noMirror: return "no_mirror"
        case .unknown: return "unknown"
        }
    }
}

// MARK: - Strip

// MARK: - Repo health strip (WAVE-043)

/// Thin exclusive health face for single-repo Código surface.
struct AtlasCodeRepoHealthStrip: View {
    let model: AtlasCodeModel
    let mirror: AtlasCodeMirrorResponse?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var face: AtlasCodeRepoHealthFace {
        AtlasCodeRepoHealthJudgment.face(model: model, mirror: mirror)
    }

    var body: some View {
        switch face {
        case .unbound:
            EmptyView()
        case .unknown, .clean, .healed, .weekActive, .violating, .mirrorBlocked:
            stripChrome
        }
    }

    private var stripChrome: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Circle()
                .fill(dotColor)
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(face.kicker)
                    .font(AtlasFont.mono(9))
                    .tracking(0.7)
                    .foregroundStyle(titleColor)
                Text(AtlasCodeRepoHealthJudgment.summaryLine(model: model, mirror: mirror))
                    .font(AtlasFont.serif(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(face.spokenFace)
        .accessibilityIdentifier(A11yID.codeRepoHealth)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: face.productWord)
    }

    private var dotColor: Color {
        switch face {
        case .mirrorBlocked, .violating: return AtlasCodePalette.alert
        case .healed: return AtlasCodePalette.healed
        case .weekActive: return AtlasTheme.accent
        case .clean: return AtlasTheme.textTertiary
        case .unknown, .unbound: return AtlasTheme.textTertiary
        }
    }

    private var titleColor: Color {
        switch face {
        case .mirrorBlocked, .violating: return AtlasCodePalette.alert
        case .healed: return AtlasCodePalette.healed
        case .weekActive: return AtlasTheme.accent
        case .clean, .unknown, .unbound: return AtlasTheme.textTertiary
        }
    }
}
