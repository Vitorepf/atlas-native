import AtlasCore
import SwiftUI

// Cycle 030 fuse → ComposerToolbar+Options.swift

extension ComposerToolbar {
    @ViewBuilder var trailingOptionsMenu: some View {
        Menu {
            optionsMenuButtons
        } label: {
            Image(systemName: "ellipsis")
                .atlasSans(17, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 32, height: 32)
                .contentShape(Circle())
        }
        .accessibilityLabel("opções da conversa")
        .accessibilityHint(spokenOptionsHint())
        .accessibilityIdentifier(A11yID.conversationOptions)
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var optionsMenuButtons: some View {
        optionsWorkspaceButton
        optionsModeButton
        optionsEffortButton
    }
}

extension ComposerToolbar {
    var optionsEffortButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onShowEffort()
        } label: {
            Label("Esforço: \(model.effort.shortLabel)", systemImage: "gauge.with.dots.needle.33percent")
        }
        .accessibilityLabel(spokenEffortLabel(model.effort))
        .accessibilityHint(spokenEffortHint())
    }
}

extension ComposerToolbar {
    var optionsModeButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onShowMode()
        } label: {
            Label("Modo: \(mode.capitalized)", systemImage: "slider.horizontal.3")
        }
        .accessibilityLabel("modo, \(mode)")
    }
}

extension ComposerToolbar {
    var optionsWorkspaceButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onShowWorkspace()
        } label: {
            Label("Workspace: \(model.workspaceName ?? "Atlas")", systemImage: "square.grid.2x2")
        }
        .accessibilityLabel("workspace, \(model.workspaceName ?? "Atlas")")
    }
}
