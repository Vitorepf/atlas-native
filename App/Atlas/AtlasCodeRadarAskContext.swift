import SwiftUI
import AtlasCore

// WAVE-011 fused

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

        if let workspace = model.workspace {
            facts.append("folders: \(workspace.folders.count)")
            facts.append("recents: \(workspace.recents.count)")
            if let root = workspace.workspaceRoot, !root.isEmpty {
                facts.append("workspace_root: \(root)")
                anchors.append("root: \(root)")
            } else if let slug = workspace.recents.first?.slug {
                facts.append("workspace_wire_fallback: \(slug) (primeiro recente)")
            } else {
                absences.append("sem workspace_root nem recentes para o wire")
            }
        } else {
            facts.append("workspace: ainda não carregado")
            absences.append("workspace wire nil até load")
        }

        let scanned = model.issuesBySlug.count
        let withIssues = model.issuesBySlug.values.filter { !$0.isEmpty }.count
        let totalIssues = model.issuesBySlug.values.flatMap { $0 }.reduce(0) { $0 + $1.count }
        if scanned > 0 {
            facts.append("repos_scanned: \(scanned)")
            facts.append("repos_with_sem_retorno: \(withIssues)")
            if totalIssues > 0 {
                facts.append("sem_retorno_signals: \(totalIssues)")
            }
            facts.append("headline: \(model.headline)")
            anchors.append("headline: \(model.headline)")
        } else {
            absences.append("nenhum scan de violações hidratado ainda")
        }

        if !model.failedSlugs.isEmpty {
            facts.append("repos_mute: \(model.failedSlugs.sorted().joined(separator: ", "))")
        }

        // WAVE-024: top attention subjects (real issue counts only).
        let top = AtlasCodeRadarJudgment.topAttention(issuesBySlug: model.issuesBySlug)
        if !top.isEmpty {
            facts.append("top_attention:")
            for item in top {
                facts.append("  \(item.slug): \(item.count) signal\(item.count == 1 ? "" : "s")")
                anchors.append("attention · \(item.slug) · \(item.count)")
            }
        } else if scanned > 0 {
            absences.append("nenhum subject com sem-retorno no scan atual (frota quieta neste load)")
        }

        absences.append("não inventar merges ou cures; julgamento soberano do workspace")

        // WAVE-162: radar screen face organ.
        let failMsg: String? = {
            if case .failed(let m) = model.phase { return m }
            return nil
        }()
        let repoCount = model.workspace.map { $0.folders.reduce(0) { $0 + $1.repos.count } + $0.recents.count }
        let screenPack = AtlasCodeRadarScreenJudgment.packFacts(
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

