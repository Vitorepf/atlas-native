import SwiftUI
import AtlasCore

// Chips de filtro workspace — peel de RootHomeSections+Conversation.

extension RootHomeSections {
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
