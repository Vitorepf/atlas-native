import SwiftUI
import AtlasCore

/// Filtros e roteamento de conversas na home — peel de RootHomeSections.
extension RootHomeSections {
    /// Conversas sem projeto (workspace nulo) — o modo "só conversar".
    var freeThreadCount: Int {
        session.threads.filter { $0.workspace == nil }.count
    }

    var homeConversationRoute: Route {
        switch homeWorkspaceFilter {
        case .some("__all"):
            return .workspace(key: nil, title: "Todas")
        case .some(let key):
            let title = session.workspaces.first(where: { $0.id == key })?.name ?? "Workspace"
            return .workspace(key: key, title: title)
        case .none:
            return .conversas
        }
    }

    var homeConversationLabel: String {
        switch homeWorkspaceFilter {
        case .some("__all"): return "Todas as conversas"
        case .some(let key): return session.workspaces.first(where: { $0.id == key })?.name ?? "Workspace"
        case .none: return "Conversas livres"
        }
    }

    var homeConversationThreadCount: Int {
        switch homeWorkspaceFilter {
        case .some("__all"): return session.threads.count
        case .some(let key): return session.threads(inWorkspace: key).count
        case .none: return freeThreadCount
        }
    }

    var homeConversationCount: Int? {
        let n = homeConversationThreadCount
        return n > 0 ? n : nil
    }

    var auditDetail: String {
        let key = homeWorkspaceFilter ?? "livres"
        let n = homeConversationCount ?? 0
        return "auditoria · filtro \(key) · \(n) threads"
    }

    @ViewBuilder
    var homeWorkspaceChips: some View {
        if showsWorkspaceChips {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    homeFilterChip("Livres", key: nil)
                    homeFilterChip("Todas", key: "__all")
                    ForEach(session.workspaces) { workspace in
                        homeFilterChip(workspace.name, key: workspace.id)
                    }
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.bottom, 10)
            }
            .accessibilityLabel(filterChipsSpokenLabel())
            .accessibilityIdentifier(A11yID.homeWorkspaceChips)
        }
    }

    func homeFilterChip(_ label: String, key: String?) -> some View {
        let active = homeWorkspaceFilter == key
        return Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            homeWorkspaceFilter = key
        } label: {
            Text(label)
                .font(.system(.caption, weight: .medium))
                .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface))
                .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: active)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(filterChipSpokenLabel(label, active: active))
        .accessibilityHint("altera o filtro de conversas na lista abaixo")
        .accessibilityAddTraits(active ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier(A11yID.homeWorkspaceChip(key ?? "__free"))
    }
}
