import SwiftUI
import PhotosUI
import AtlasCore

// Seed → ConversationView+InitSeed.swift

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
        // Pergunta semeada por quem abriu (ex.: a folha do commit): o operador
        // chega com o assunto escrito e edita se quiser. Semear NÃO é enviar —
        // mandar sozinho seria decidir por ele.
        self.emptyPrompt = emptyPrompt
        self.emptySuggestions = emptySuggestions
        self.onThread = onThread
        _model = State(initialValue: Self.seededModel(
            client: client,
            threadId: threadId,
            taskKind: taskKind,
            workspace: workspace,
            draft: draft,
            turnFacts: turnFacts
        ))
    }
}
