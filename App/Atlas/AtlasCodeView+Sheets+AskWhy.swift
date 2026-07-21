import SwiftUI
import AtlasCore

// Folhas ask/why do grafo.
// Peel forest fused cycle 017 (AskWhy/AskSheet/WhySheet/AskConversation peels).
// Experiência de página editorial: fundo Atlas, detent large, sem grabber
// de sheet nem botão voltar — fecha no gesto.

struct AtlasCodeAskWhySheetsModifier: ViewModifier {
    let session: AtlasSession
    let model: AtlasCodeModel
    let askModel: AtlasCodeAskModel
    @Binding var showsAskCard: Bool
    @Binding var whyFileTarget: AtlasCodeView.WhyFileTarget?
    @Binding var askThreadId: ThreadID?
    @Binding var askDraft: String

    func body(content: Content) -> some View {
        askWhyWhySheet(on: askWhyAskSheet(on: content))
    }

    func askWhyAskSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showsAskCard) {
                askConversationSheet
            }
    }

    func askWhyWhySheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $whyFileTarget) { target in
                AtlasCodeWhySheet(client: session.client, repo: model.repo, file: target.path)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
    }

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
            onThread: { askThreadId = $0 },
            hidesNavigationBack: true
        )
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(AtlasTheme.bg)
        .presentationCornerRadius(28)
        .interactiveDismissDisabled(false)
    }
}
