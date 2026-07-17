import SwiftUI
import AtlasCore

// Folhas ask/why — peel de AtlasCodeView+Sheets (régua ≤100).
// Ask → AtlasCodeView+Sheets+AskConversation.swift

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
        askConversationSheet
      }
      .sheet(item: $whyFileTarget) { target in
        AtlasCodeWhySheet(client: session.client, repo: model.repo, file: target.path)
          .presentationDetents([.large])
          .presentationDragIndicator(.visible)
      }
  }
}
