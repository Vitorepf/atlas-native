import SwiftUI
import AtlasCore

// Menu de opções do trailing — peel de ComposerToolbar+Trailing.

extension ComposerToolbar {
    @ViewBuilder var trailingOptionsMenu: some View {
        Menu {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onShowWorkspace()
            } label: {
                Label("Workspace: \(model.workspaceName ?? "Atlas")", systemImage: "square.grid.2x2")
            }
            .accessibilityLabel("workspace, \(model.workspaceName ?? "Atlas")")
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onShowMode()
            } label: {
                Label("Modo: \(mode.capitalized)", systemImage: "slider.horizontal.3")
            }
            .accessibilityLabel("modo, \(mode)")
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onShowEffort()
            } label: {
                Label("Esforço: \(model.effort.shortLabel)", systemImage: "gauge.with.dots.needle.33percent")
            }
            .accessibilityLabel(spokenEffortLabel(model.effort))
            .accessibilityHint(spokenEffortHint())
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 32, height: 32)
                .contentShape(Circle())
        }
        .accessibilityLabel("opções da conversa")
        .accessibilityHint(spokenOptionsHint())
        .accessibilityIdentifier(A11yID.conversationOptions)
    }
}
