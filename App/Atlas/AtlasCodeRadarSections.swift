import AtlasCore
import SwiftUI

// MARK: - Seções do AtlasCodeRadarView
// Extraídas sem mudança de comportamento — a view só compõe.

struct AtlasCodeRadarStatusCapsule: View {
    let model: AtlasCodeWorkspaceModel

    var body: some View {
        // Silêncio = produto: saudável (sem violações) → caption quieta, sem
        // chrome de alarme/afirmação verde. Barulho só com exceção real.
        Group {
            switch model.scanState {
            case .clean, .unknown:
                silentCaption
            case .violating:
                alarmCapsule
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityLabel(model.headline)
        .accessibilityIdentifier(A11yID.radarStatus)
    }

    /// Caption baixa — mesmo padrão da frota («frota» / «fila») sem incidente.
    private var silentCaption: some View {
        Text(model.scanState == .clean ? "código" : model.headline)
            .font(.system(size: 11, weight: .semibold))
            .tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.vertical, 7)
    }

    private var alarmCapsule: some View {
        HStack(spacing: 7) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 10, weight: .semibold))
            Text(model.headline)
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
        }
        .foregroundStyle(AtlasCodePalette.alert)
        .padding(.horizontal, 15)
        .padding(.vertical, 7)
        .background(Capsule().fill(AtlasCodePalette.alert.opacity(0.09)))
        .overlay(Capsule().strokeBorder(AtlasCodePalette.alert.opacity(0.35), lineWidth: 1))
    }
}

struct AtlasCodeRadarSectionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.3)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.bottom, 8)
    }
}

struct AtlasCodeRadarRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(AtlasTheme.separator.opacity(0.5))
            .frame(height: 0.5)
    }
}

struct AtlasCodeRadarLoadedContent: View {
    let workspace: AtlasCodeWorkspaceResponse
    let model: AtlasCodeWorkspaceModel
    let onOpenRepo: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AtlasCodeRadarStatusCapsule(model: model)
                    .padding(.bottom, 18)

                if !workspace.recents.isEmpty {
                    AtlasCodeRadarSectionLabel(text: "RECENTES")
                    ForEach(workspace.recents) { repo in
                        AtlasCodeRepoRow(repo: repo, issues: model.issues(for: repo.slug), trunk: model.trunk(for: repo.slug), showsFolder: true) {
                            onOpenRepo(repo.slug)
                        }
                        if repo.id != workspace.recents.last?.id { AtlasCodeRadarRowDivider() }
                    }
                }

                if !workspace.folders.isEmpty {
                    AtlasCodeRadarSectionLabel(text: "PASTAS")
                        .padding(.top, 22)
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

                if !workspace.loose.isEmpty {
                    AtlasCodeRadarSectionLabel(text: "AVULSOS")
                        .padding(.top, 22)
                    ForEach(workspace.loose) { repo in
                        AtlasCodeRepoRow(repo: repo, issues: model.issues(for: repo.slug), trunk: model.trunk(for: repo.slug), showsFolder: false) {
                            onOpenRepo(repo.slug)
                        }
                        if repo.id != workspace.loose.last?.id { AtlasCodeRadarRowDivider() }
                    }
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
    }
}
