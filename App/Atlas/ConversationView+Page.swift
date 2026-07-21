import AtlasCore
import PhotosUI
import SwiftUI

// Cycle 035 fuse → ConversationView+Page.swift

extension ConversationView {
    @ViewBuilder
    var conversationPage: some View {
        conversationPageChrome(
            ZStack(alignment: .bottom) {
                AtlasTheme.bg.ignoresSafeArea()
                conversationMessagesStack
                conversationComposerBind
            }
        )
    }
}

extension ConversationView {
    func conversationPageChrome<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .scrollDismissesKeyboard(.interactively)
            .accessibilityIdentifier(A11yID.conversationScreen)
            .accessibilityLabel(spokenConversationScreenLabel())
            .accessibilityHint(
                hidesNavigationBack
                    ? "arraste para baixo para fechar"
                    : ConversationViewA11y.screenHint
            )
            .overlay(alignment: .top) { toast }
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.toast)
    }
}

extension ConversationView {
    var conversationMessagesStack: some View {
        VStack(spacing: 0) {
            header
            cacheAgeSeal
            handoffReceipt
            conversationMessagesView
        }
    }
}

extension ConversationView {
    var conversationMessagesModelArgs: (
        model: ConversationModel,
        reduceMotion: Bool,
        emptyPrompt: String?,
        emptySuggestions: [String]?
    ) {
        (
            model: model,
            reduceMotion: reduceMotion,
            emptyPrompt: emptyPrompt,
            emptySuggestions: emptySuggestions
        )
    }
}

extension ConversationView {
    var conversationMessagesTraceArgs: (
        awayFromBottom: Binding<Bool>,
        lastScrollAt: Binding<CFAbsoluteTime>,
        lastScrollBubbleCount: Binding<Int>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>,
        onEditResend: (ChatBubble) -> Void,
        onCopy: (String, String) -> Void
    ) {
        (
            awayFromBottom: $awayFromBottom,
            lastScrollAt: $lastScrollAt,
            lastScrollBubbleCount: $lastScrollBubbleCount,
            reviewTrace: $reviewTrace,
            artifactTrace: $artifactTrace,
            steerTrace: $steerTrace,
            onEditResend: editAndResend,
            onCopy: copy
        )
    }
}

extension ConversationView {
    var conversationMessagesView: some View {
        let modelArgs = conversationMessagesModelArgs
        let traceArgs = conversationMessagesTraceArgs
        return ConversationMessages(
            model: modelArgs.model,
            reduceMotion: modelArgs.reduceMotion,
            emptyPrompt: modelArgs.emptyPrompt,
            emptySuggestions: modelArgs.emptySuggestions,
            awayFromBottom: traceArgs.awayFromBottom,
            lastScrollAt: traceArgs.lastScrollAt,
            lastScrollBubbleCount: traceArgs.lastScrollBubbleCount,
            reviewTrace: traceArgs.reviewTrace,
            artifactTrace: traceArgs.artifactTrace,
            steerTrace: traceArgs.steerTrace,
            onEditResend: traceArgs.onEditResend,
            onCopy: traceArgs.onCopy
        )
    }
}

extension ConversationView {
    var conversationComposerBind: some View {
        conversationComposerCard
    }
}

extension ConversationView {
    var conversationComposerSheetTraceAggregate: (
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        showFileImporter: Binding<Bool>,
        showCamera: Binding<Bool>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>
    ) {
        let sheets = conversationComposerSheetFlagBindings
        let traces = conversationComposerTraceBindings
        return (
            mode: sheets.mode,
            showModeSheet: sheets.showModeSheet,
            showWorkspaceSheet: sheets.showWorkspaceSheet,
            showEffortSheet: sheets.showEffortSheet,
            showQueueSheet: sheets.showQueueSheet,
            showAttachmentSheet: sheets.showAttachmentSheet,
            pickedPhoto: sheets.pickedPhoto,
            showFileImporter: sheets.showFileImporter,
            showCamera: sheets.showCamera,
            reviewTrace: traces.reviewTrace,
            artifactTrace: traces.artifactTrace,
            steerTrace: traces.steerTrace
        )
    }
}

extension ConversationView {
    var conversationComposerSheetFlagBindings: (
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        showFileImporter: Binding<Bool>,
        showCamera: Binding<Bool>
    ) {
        (
            mode: $mode,
            showModeSheet: $showModeSheet,
            showWorkspaceSheet: $showWorkspaceSheet,
            showEffortSheet: $showEffortSheet,
            showQueueSheet: $showQueueSheet,
            showAttachmentSheet: $showAttachmentSheet,
            pickedPhoto: $pickedPhoto,
            showFileImporter: $showFileImporter,
            showCamera: $showCamera
        )
    }
}

extension ConversationView {
    var conversationComposerTraceBindings: (
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

extension ConversationView {
    var conversationComposerSheetBindings: (
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        showFileImporter: Binding<Bool>,
        showCamera: Binding<Bool>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>
    ) {
        conversationComposerSheetTraceAggregate
    }
}

extension ConversationView {
    func conversationComposerInit(
        sessionArgs: (
            model: ConversationModel,
            session: AtlasSession,
            reduceMotion: Bool,
            focused: FocusState<Bool>.Binding
        ),
        bindings: (
            mode: Binding<String>,
            showModeSheet: Binding<Bool>,
            showWorkspaceSheet: Binding<Bool>,
            showEffortSheet: Binding<Bool>,
            showQueueSheet: Binding<Bool>,
            showAttachmentSheet: Binding<Bool>,
            pickedPhoto: Binding<PhotosPickerItem?>,
            showFileImporter: Binding<Bool>,
            showCamera: Binding<Bool>,
            reviewTrace: Binding<ConversationReviewTraceRef?>,
            artifactTrace: Binding<ConversationReviewTraceRef?>,
            steerTrace: Binding<ConversationSteerTraceRef?>
        )
    ) -> ConversationComposer {
        ConversationComposer(
            model: sessionArgs.model,
            session: sessionArgs.session,
            reduceMotion: sessionArgs.reduceMotion,
            focused: sessionArgs.focused,
            mode: bindings.mode,
            showModeSheet: bindings.showModeSheet,
            showWorkspaceSheet: bindings.showWorkspaceSheet,
            showEffortSheet: bindings.showEffortSheet,
            showQueueSheet: bindings.showQueueSheet,
            showAttachmentSheet: bindings.showAttachmentSheet,
            pickedPhoto: bindings.pickedPhoto,
            showFileImporter: bindings.showFileImporter,
            showCamera: bindings.showCamera,
            reviewTrace: bindings.reviewTrace,
            artifactTrace: bindings.artifactTrace,
            steerTrace: bindings.steerTrace
        )
    }
}

extension ConversationView {
    func conversationComposerSessionArgs(
        focused: FocusState<Bool>.Binding
    ) -> (
        model: ConversationModel,
        session: AtlasSession,
        reduceMotion: Bool,
        focused: FocusState<Bool>.Binding
    ) {
        (
            model: model,
            session: session,
            reduceMotion: reduceMotion,
            focused: focused
        )
    }
}

extension ConversationView {
    func conversationComposerCoreArgs(
        bindings: (
            mode: Binding<String>,
            showModeSheet: Binding<Bool>,
            showWorkspaceSheet: Binding<Bool>,
            showEffortSheet: Binding<Bool>,
            showQueueSheet: Binding<Bool>,
            showAttachmentSheet: Binding<Bool>,
            pickedPhoto: Binding<PhotosPickerItem?>,
            showFileImporter: Binding<Bool>,
            showCamera: Binding<Bool>,
            reviewTrace: Binding<ConversationReviewTraceRef?>,
            artifactTrace: Binding<ConversationReviewTraceRef?>,
            steerTrace: Binding<ConversationSteerTraceRef?>
        )
    ) -> ConversationComposer {
        conversationComposerInit(
            sessionArgs: conversationComposerSessionArgs(focused: $focused),
            bindings: bindings
        )
    }
}

extension ConversationView {
    var conversationComposerArgs: ConversationComposer {
        conversationComposerCoreArgs(bindings: conversationComposerSheetBindings)
    }
}

extension ConversationView {
    var conversationComposerCard: some View {
        conversationComposerArgs
    }
}
