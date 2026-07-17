import SwiftUI
import AtlasCore

// Ask conversation sheet — peel de AtlasCodeView+Sheets+AskWhy.

extension AtlasCodeAskWhySheetsModifier {
    var askConversationSheet: some View {
        ConversationView(
            client: session.client,
            threadId: askThreadId,
            title: "Código · \(model.repo)",
            emptyPrompt: "O que você quer saber deste repositório?",
            emptySuggestions: AtlasCodeAskSuggestions.all,
            taskKind: "code",
            workspace: model.repo,
            draft: askDraft,
            turnFacts: { [askModel] question in await askModel.facts(for: question) },
            onThread: { askThreadId = $0 }
        )
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.ultraThinMaterial)
    }
}
