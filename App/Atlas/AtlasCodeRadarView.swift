import SwiftUI
import AtlasCore

// WAVE-011 fused


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
                AtlasCodeFolderRowA11y.spokenFolder(
                    name: folder.name,
                    repositoryCount: folder.repositories,
                    verifiedExceptionCount: verifiedExceptionCount,
                    isExpanded: isExpanded
                )
            )
            .accessibilityHint(AtlasCodeFolderRowA11y.spokenHint(isExpanded: isExpanded))
            .accessibilityIdentifier(A11yID.radarFolder(folder.slug))
    }
}

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

