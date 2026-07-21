import SwiftUI
import AtlasCore

// WAVE-011 fused

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

        return AgenticOccasionPack(
            surface: "code.radar",
            subject: "workspace do operador",
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: .readChat
        ).render()
    }
}

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

