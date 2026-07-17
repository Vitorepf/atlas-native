import SwiftUI
import AtlasCore

// Strip + toolbar do composer — peel de ConversationComposer+CardBody.
// Attach → ConversationComposer+CardAttach.swift

extension ConversationComposer {
    @ViewBuilder
    var composerStripToolbar: some View {
        composerAttachmentStrip
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
