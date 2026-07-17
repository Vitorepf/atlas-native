import SwiftUI
import AtlasCore

// Folhas do grafo — peel de AtlasCodeView; zero mudança de rota.
// Ask/Why → +AskWhy · Provenance/Heal → +Sheets+Provenance

extension View {
  func atlasCodeSheets(
    session: AtlasSession,
    model: AtlasCodeModel,
    provenanceModel: AtlasCodeProvenanceModel,
    askModel: AtlasCodeAskModel,
    selectedNode: Binding<AtlasCodeGraphNode?>,
    showsHealReceipt: Binding<Bool>,
    showsAskCard: Binding<Bool>,
    whyFileTarget: Binding<AtlasCodeView.WhyFileTarget?>,
    askThreadId: Binding<ThreadID?>,
    askDraft: Binding<String>,
    onProvenanceAsk: @escaping (AtlasCodeGraphNode) -> Void
  ) -> some View {
    modifier(AtlasCodeSheetsModifier(
      session: session,
      model: model,
      provenanceModel: provenanceModel,
      askModel: askModel,
      selectedNode: selectedNode,
      showsHealReceipt: showsHealReceipt,
      showsAskCard: showsAskCard,
      whyFileTarget: whyFileTarget,
      askThreadId: askThreadId,
      askDraft: askDraft,
      onProvenanceAsk: onProvenanceAsk
    ))
  }
}

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
