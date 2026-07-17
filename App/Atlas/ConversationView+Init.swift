import SwiftUI
import PhotosUI
import AtlasCore

// Seed → ConversationView+InitSeed.swift
// ModelState → ConversationView+Init+ModelState.swift

extension ConversationView {
    init(
        client: AtlasClient,
        threadId: ThreadID?,
        title: String,
        emptyPrompt: String? = nil,
        emptySuggestions: [String]? = nil,
        taskKind: String? = nil,
        workspace: String? = nil,
        draft: String = "",
        turnFacts: ((String) async -> String?)? = nil,
        onThread: ((ThreadID) -> Void)? = nil
    ) {
        self.title = title
        self.startFocused = threadId == nil
        self.emptyPrompt = emptyPrompt
        self.emptySuggestions = emptySuggestions
        self.onThread = onThread
        _model = Self.initModelState(
            client: client,
            threadId: threadId,
            taskKind: taskKind,
            workspace: workspace,
            draft: draft,
            turnFacts: turnFacts
        )
    }
}
