import SwiftUI
import AtlasCore

// Sheets modifier — peel de AtlasCodeView+Sheets.
// Ask/Why → +AskWhy · Provenance/Heal → +Sheets+Provenance

struct AtlasCodeSheetsModifier: ViewModifier {
  let session: AtlasSession
  let model: AtlasCodeModel
  let provenanceModel: AtlasCodeProvenanceModel
  let askModel: AtlasCodeAskModel
  @Binding var selectedNode: AtlasCodeGraphNode?
  @Binding var showsHealReceipt: Bool
  @Binding var showsAskCard: Bool
  @Binding var whyFileTarget: AtlasCodeView.WhyFileTarget?
  @Binding var askThreadId: ThreadID?
  @Binding var askDraft: String
  let onProvenanceAsk: (AtlasCodeGraphNode) -> Void

  func body(content: Content) -> some View {
    provenanceAndHealSheets(on: content)
      .modifier(AtlasCodeAskWhySheetsModifier(
        session: session,
        model: model,
        askModel: askModel,
        showsAskCard: $showsAskCard,
        whyFileTarget: $whyFileTarget,
        askThreadId: $askThreadId,
        askDraft: $askDraft
      ))
  }
}
