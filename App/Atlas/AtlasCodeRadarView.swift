import SwiftUI
import AtlasCore

// WAVE-011 fused

// --- AtlasCodeRadarFolderRow+A11y.swift ---
enum AtlasCodeFolderRowA11y {
    static func spokenFolder(
        name: String,
        repositoryCount: Int,
        verifiedExceptionCount: Int,
        isExpanded: Bool
    ) -> String {
        var parts = [name, spokenRepoCount(repositoryCount)]
        if verifiedExceptionCount > 0, let phrase = AtlasCodeFolderRowA11yExceptions.exceptionPhrase(verifiedExceptionCount) {
            parts.append(phrase)
        }
        if let expanded = spokenFolderExpanded(isExpanded) { parts.append(expanded) }
        return parts.joined(separator: ", ")
    }
}

// --- AtlasCodeRadarFolderRow+A11yExceptions.swift ---
enum AtlasCodeFolderRowA11yExceptions {
    static func exceptionPhrase(_ verifiedExceptionCount: Int) -> String? {
        guard verifiedExceptionCount > 0 else { return nil }
        return "\(verifiedExceptionCount) sem retorno\(verifiedExceptionCount == 1 ? "" : "s") verificado\(verifiedExceptionCount == 1 ? "" : "s")"
    }
}

// --- AtlasCodeRadarFolderRow+A11yFolderExpanded.swift ---
extension AtlasCodeFolderRowA11y {
    static func spokenFolderExpanded(_ isExpanded: Bool) -> String? {
        isExpanded ? "expandida" : nil
    }
}

// --- AtlasCodeRadarFolderRow+A11yHint.swift ---
extension AtlasCodeFolderRowA11y {
    static func spokenHint(isExpanded: Bool) -> String {
        isExpanded ? "recolhe a pasta" : "expande a pasta"
    }
}

// --- AtlasCodeRadarFolderRow+A11yRepoCount.swift ---
extension AtlasCodeFolderRowA11y {
    static func spokenRepoCount(_ repositoryCount: Int) -> String {
        repositoryCount == 1 ? "1 repositório" : "\(repositoryCount) repositórios"
    }
}

// --- AtlasCodeRadarFolderRow+Header+Leading.swift ---
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

// --- AtlasCodeRadarFolderRow+Header+Trailing.swift ---
extension AtlasCodeFolderRow {
    var folderHeaderTrailing: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 6)
            exceptionBadge
            folderHeaderChevron
        }
    }
}

// --- AtlasCodeRadarFolderRow+Header.swift ---
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

// --- AtlasCodeRadarFolderRow+HeaderChevron.swift ---
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

// --- AtlasCodeRadarFolderRow+HeaderTitle.swift ---
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

// --- AtlasCodeRadarFolderRow+Toggle+A11y.swift ---
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

// --- AtlasCodeRadarLoadedContent+Folders+Header.swift ---
extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarFoldersHeader: some View {
        if !workspace.folders.isEmpty {
            AtlasCodeRadarSectionLabel(text: "PASTAS", accessibilityID: A11yID.radarFolders)
                .padding(.top, 22)
        }
    }
}

// --- AtlasCodeRadarLoadedContent+Folders+Loop.swift ---
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
                    onToggle: { Task { await model.toggle(folder) } },
                    onOpenRepo: onOpenRepo
                )
                if folder.id != workspace.folders.last?.id { AtlasCodeRadarRowDivider() }
            }
        }
    }
}

// --- AtlasCodeRadarLoadedContent+Folders.swift ---
extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarFoldersAndLoose: some View {
        radarFoldersHeader
        radarFoldersLoop
        radarLooseSection
    }
}

// --- AtlasCodeRadarLoadedContent+Loose.swift ---
extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarLooseSection: some View {
        if !workspace.loose.isEmpty {
            AtlasCodeRadarSectionLabel(text: "AVULSOS", accessibilityID: A11yID.radarLoose)
                .padding(.top, 22)
            ForEach(workspace.loose) { repo in
                AtlasCodeRepoRow(repo: repo, issues: model.issues(for: repo.slug), trunk: model.trunk(for: repo.slug), showsFolder: false) {
                    onOpenRepo(repo.slug)
                }
                if repo.id != workspace.loose.last?.id { AtlasCodeRadarRowDivider() }
            }
        }
    }
}

// --- AtlasCodeRadarLoadedContent+Sections+Recents.swift ---
extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarRecentsSection: some View {
        if !workspace.recents.isEmpty {
            AtlasCodeRadarSectionLabel(text: "RECENTES", accessibilityID: A11yID.radarRecents)
            ForEach(workspace.recents) { repo in
                AtlasCodeRepoRow(repo: repo, issues: model.issues(for: repo.slug), trunk: model.trunk(for: repo.slug), showsFolder: true) {
                    onOpenRepo(repo.slug)
                }
                if repo.id != workspace.recents.last?.id { AtlasCodeRadarRowDivider() }
            }
        }
    }
}

// --- AtlasCodeRadarLoadedContent+Sections.swift ---
extension AtlasCodeRadarLoadedContent {
    @ViewBuilder
    var radarSections: some View {
        AtlasCodeRadarStatusCapsule(model: model)
            .padding(.bottom, 18)

        radarRecentsSection

        radarFoldersAndLoose
    }
}

// --- AtlasCodeRadarLoadedContent.swift ---
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

// --- AtlasCodeRadarRows+A11y.swift ---
enum AtlasCodeRadarRowsA11y {
    static let repoHint = "abre o grafo do repositório"
}

