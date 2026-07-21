import SwiftUI
import AtlasCore

// Toolbar row — peel de ConversationComposer+CardStrip.

extension ConversationComposer {
    @ViewBuilder
    var composerToolbarOnly: some View {
        ComposerToolbar(
            model: model,
            reduceMotion: reduceMotion,
            focused: focused,
            expanded: expanded,
            mode: mode,
            liveBubble: liveBubble,
            onAttach: { showAttachmentSheet = true },
            onShowWorkspace: { showWorkspaceSheet = true },
            onShowMode: { showModeSheet = true },
            onShowEffort: { showEffortSheet = true },
            onSend: send
        )
    }
}
