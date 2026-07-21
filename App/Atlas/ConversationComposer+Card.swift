import AtlasCore
import PhotosUI
import SwiftUI

// Cycle 032 fuse → ConversationComposer+Card.swift

extension ConversationComposer {
    var composerCardSpokenLabel: String {
        ConversationComposerA11y.spokenCard(
            expanded: expanded,
            draftCount: model.drafts.count,
            queueCount: model.queuedMessages.count,
            isSending: model.isSending
        )
    }
}

extension ConversationComposer {
    var composerCardSurface: some View {
        VStack(alignment: .leading, spacing: expanded ? 12 : 0) {
            composerCardBody
        }
        .padding(composerCardPadding)
        .background(composerSurface)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.86), value: expanded)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.86), value: model.drafts)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(composerCardSpokenLabel)
        .accessibilityHint(ConversationComposerA11y.cardHint)
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerAttachmentOnly: some View {
        composerAttachmentStrip
    }
}

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

extension ConversationComposer {
    @ViewBuilder
    var composerStripToolbar: some View {
        composerAttachmentOnly
        composerToolbarOnly
    }
}

// Keyboard grabber — morto. Teclado dispensa no scroll / gesto da sheet.
// (A barra "fechar" lia como chrome de card e quebrava a pílula do grafo.)

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyGrabber: some View {
        EmptyView()
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyLive: some View {
        liveExecutionSection
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyQueue: some View {
        queueChipSection
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyStrip: some View {
        composerStripToolbar
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerCardBody: some View {
        composerCardBodyLive
        composerCardBodyQueue
        composerCardBodyGrabber
        composerCardBodyStrip
    }
}

extension ConversationComposer {
    var composerCardSheetFlagArgs: (
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>
    ) {
        (
            mode: $mode,
            showModeSheet: $showModeSheet,
            showWorkspaceSheet: $showWorkspaceSheet,
            showEffortSheet: $showEffortSheet,
            showQueueSheet: $showQueueSheet,
            showAttachmentSheet: $showAttachmentSheet,
            showCamera: $showCamera,
            showFileImporter: $showFileImporter,
            pickedPhoto: $pickedPhoto
        )
    }
}

extension ConversationComposer {
    var composerCardSheetTraceArgs: (
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>
    ) {
        (
            reviewTrace: $reviewTrace,
            artifactTrace: $artifactTrace,
            steerTrace: $steerTrace
        )
    }
}

extension ConversationComposer {
    func composerCardSheets<V: View>(_ card: V) -> some View {
        let flags = composerCardSheetFlagArgs
        let traces = composerCardSheetTraceArgs
        return card.conversationComposerSheets(
            model: model,
            session: session,
            mode: flags.mode,
            showModeSheet: flags.showModeSheet,
            showWorkspaceSheet: flags.showWorkspaceSheet,
            showEffortSheet: flags.showEffortSheet,
            showQueueSheet: flags.showQueueSheet,
            showAttachmentSheet: flags.showAttachmentSheet,
            showCamera: flags.showCamera,
            showFileImporter: flags.showFileImporter,
            pickedPhoto: flags.pickedPhoto,
            reviewTrace: traces.reviewTrace,
            artifactTrace: traces.artifactTrace,
            steerTrace: traces.steerTrace,
            onSteerSubmit: submitSteer
        )
    }
}

extension ConversationComposer {
    var composerCardPadding: EdgeInsets {
        expanded
            ? EdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
            : EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    }
}

extension ConversationComposer {
    var composerAttachmentStrip: some View {
        AttachmentStrip(
            drafts: model.drafts,
            reduceMotion: reduceMotion,
            uploadPercent: model.uploadPercent,
            onRemove: { model.removeDraft($0) },
            onFailedTap: { model.toast = $0 }
        )
    }
}

extension ConversationComposer {
    var composerCard: some View {
        composerCardSheets(composerCardSurface)
    }
}
