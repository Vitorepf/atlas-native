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
