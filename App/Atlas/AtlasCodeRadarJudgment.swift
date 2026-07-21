import Foundation
import AtlasCore

// WAVE-024 — fleet judgment helpers (presentation-only; never invent scan totals).

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
