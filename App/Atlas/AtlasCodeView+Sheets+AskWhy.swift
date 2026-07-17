import SwiftUI
import AtlasCore

// Folhas ask/why — peel de AtlasCodeView+Sheets (régua ≤100).

struct AtlasCodeAskWhySheetsModifier: ViewModifier {
  let session: AtlasSession
  let model: AtlasCodeModel
  let askModel: AtlasCodeAskModel
  @Binding var showsAskCard: Bool
  @Binding var whyFileTarget: AtlasCodeView.WhyFileTarget?
  @Binding var askThreadId: ThreadID?
  @Binding var askDraft: String

  func body(content: Content) -> some View {
    content
      .sheet(isPresented: $showsAskCard) {
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
      .sheet(item: $whyFileTarget) { target in
        AtlasCodeWhySheet(client: session.client, repo: model.repo, file: target.path)
          .presentationDetents([.large])
          .presentationDragIndicator(.visible)
      }
  }
}
