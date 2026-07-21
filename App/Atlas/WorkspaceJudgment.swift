import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: Workspace judgments+chrome+ask fused

// MARK: - WorkspaceJudgment

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

    static func screenHint(freeOnly: Bool) -> String {
        freeOnly ? "conversas sem workspace" : "conversas deste workspace"
    }

    // MARK: Chrome (header / filter / pill)

    static let backLabel = "voltar"
    static let areaFilterHint = "filtra conversas já carregadas"
    static let newConversationLabel = "nova conversa"
    static let newConversationHint = "abre o compositor para escrever ao Atlas"

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
// MARK: - WorkspaceEmptyJudgment

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
            return "“Nada em \(label) — por enquanto.”"
        case .free:
            return "“Nenhuma conversa sem projeto ainda.”"
        case .workspace(let title):
            return "“Nenhuma conversa em \(title) ainda.”"
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
        editorialStack
            .frame(maxWidth: .infinity).padding(.top, 72).padding(.horizontal, 40)
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
                .font(AtlasFont.serifItalic(17)).foregroundStyle(AtlasTheme.textSecondary)
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
    var retryHint: String = "reconecta ao servidor Atlas"
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
    static func invite(workspaceName: String) -> String {
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
    static let freeInvite = "Escreva livremente"
}
// MARK: - WorkspacePickerJudgment

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

    static let loadingCopy = "lendo os repositórios do Mac…"
    static let failedHeadline = "O Mac não respondeu."
    static let retryLabel = "Tentar de novo"
    static let noRepoLabel = "sem repositório"
    static let noRepoHint = "conversa geral com o Atlas, sem projeto"
    static let noRepoTitle = "Sem repositório"
    static let noRepoSubtitle = "conversar ou pesquisar, sem projeto"
    static let reposCaption = "REPOSITÓRIOS"
    static let searchPrompt = "Buscar repositórios"
    static let rowHint = "abre o workspace deste repositório"
    static let currentRepoBadgeLabel = "atual"
    static let closeLabel = "Fechar"

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

    static func spokenLoading() -> String { loadingCopy }

    static func spokenFailed() -> String { failedHeadline }

    static func spokenNoRepo() -> String { noRepoLabel }

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
// MARK: - WorkspaceThreadJudgment

// MARK: - Workspace / Search catalog judgment (WAVE-032)

/// Pure live-first ranking for thread catalogs — parity with LiveNow attention.
/// Prefer threadId identity; never invent live without signal.
enum WorkspaceThreadJudgment {

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

    static let profileLabel = "perfil do operador"
    static let profileHint = "abre seu perfil e o estado da sessão"

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

    static func threadHint(isRunning: Bool) -> String {
        isRunning ? "Atlas executando nesta conversa" : "abre a conversa"
    }
}
