import AtlasCore
import SwiftUI

// IDLE-COMPRESS peel: sheet modifiers from AtlasCodeSurface (canon §7.2 same domain)

struct AtlasCodeAskWhySheetsModifier: ViewModifier {
  let session: AtlasSession
  let model: AtlasCodeModel
  let provenanceModel: AtlasCodeProvenanceModel
  let askModel: AtlasCodeAskModel
  let graphStateFilter: AtlasCodeGraphStateFilter
  @Binding var askFocusNode: AtlasCodeGraphNode?
  @Binding var showsAskCard: Bool
  @Binding var whyFileTarget: AtlasCodeView.WhyFileTarget?
  @Binding var askThreadId: ThreadID?
  @Binding var askDraft: String

  func body(content: Content) -> some View {
    askWhyWhySheet(on: askWhyAskSheet(on: content))
  }
}

extension AtlasCodeAskWhySheetsModifier {
    var askConversationSheet: some View {
        ConversationView(
            client: session.client,
            threadId: askThreadId,
            title: "Código · \(model.repo)",
            emptyPrompt: AtlasCodeAskContext.emptyPrompt(focusLegend: askModel.sheetFocusLegend),
            emptySuggestions: AtlasCodeAskContext.emptySuggestions,
            taskKind: "code",
            workspace: model.repo,
            draft: askDraft,
            turnFacts: { question in
                // WAVE-019: occasion pack first; optional server ask facts append.
                // WAVE-167: provenance phase for focused commit honesty.
                let focus = askFocusNode
                let server = await askModel.facts(for: question)
                return AtlasCodeAskContext.facts(
                    model: model,
                    focusNode: focus,
                    focusLegend: askModel.sheetFocusLegend,
                    isAnchoring: askModel.isAnchoring,
                    graphStateFilter: graphStateFilter,
                    serverAskFacts: server,
                    provenancePhase: provenanceModel.phase
                )
            },
            onThread: { askThreadId = $0 },
            hidesNavigationBack: true
        )
        .agenticAskSheetPresentation()
        .interactiveDismissDisabled(false)
    }
}

extension AtlasCodeAskWhySheetsModifier {
    func askWhyAskSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showsAskCard) {
                askConversationSheet
            }
    }
}

extension AtlasCodeAskWhySheetsModifier {
    func askWhyWhySheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $whyFileTarget) { target in
                AtlasCodeWhySheet(client: session.client, repo: model.repo, file: target.path)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
    }
}


extension AtlasCodeSheetsModifier {
  @ViewBuilder
  func healReceiptSheet<Content: View>(on content: Content) -> some View {
    content
      .sheet(isPresented: $showsHealReceipt) {
        if let heal = model.heal {
          // WAVE-048: pass undoError; sheet stays open so failure is honest.
          AtlasCodeHealReceiptSheet(
            heal: heal,
            undoError: model.undoError
          ) {
            Task { await model.undoLastHeal() }
          }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
      }
  }

  @ViewBuilder
  func provenanceAndHealSheets<Content: View>(on content: Content) -> some View {
    healReceiptSheet(on: provenanceSheetBind(on: content))
  }
}

extension AtlasCodeSheetsModifier {
    func provenanceSheetContent(for node: AtlasCodeGraphNode) -> AtlasCodeProvenanceSheet {
        AtlasCodeProvenanceSheet(
            client: session.client,
            repo: model.repo,
            node: node,
            state: model.state(for: node),
            ruleId: model.ruleId(for: node),
            ruleCanon: model.ruleCanon(for: node),
            trunk: model.violations?.trunk,
            phase: provenanceModel.phase,
            onAsk: { onProvenanceAsk(node) }
        )
    }
}

extension AtlasCodeSheetsModifier {
    func provenanceSheetPresent<Content: View>(_ sheet: Content) -> some View {
        sheet
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
    }
}

extension AtlasCodeSheetsModifier {
    @ViewBuilder
    func provenanceSheetBind<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $selectedNode) { node in
                provenanceSheetPresent(provenanceSheetContent(for: node))
            }
    }
}

struct AtlasCodeSheetsModifier: ViewModifier {
  let session: AtlasSession
  let model: AtlasCodeModel
  let provenanceModel: AtlasCodeProvenanceModel
  let askModel: AtlasCodeAskModel
  let graphStateFilter: AtlasCodeGraphStateFilter
  @Binding var selectedNode: AtlasCodeGraphNode?
  @Binding var askFocusNode: AtlasCodeGraphNode?
  @Binding var showsHealReceipt: Bool
  @Binding var showsAskCard: Bool
  @Binding var whyFileTarget: AtlasCodeView.WhyFileTarget?
  @Binding var askThreadId: ThreadID?
  @Binding var askDraft: String
  let onProvenanceAsk: (AtlasCodeGraphNode) -> Void

  func body(content: Content) -> some View {
    askWhySheetsBind(provenanceAndHealSheets(on: content))
  }

  func askWhySheetsBind<Content: View>(_ content: Content) -> some View {
    content.modifier(AtlasCodeAskWhySheetsModifier(
      session: session,
      model: model,
      provenanceModel: provenanceModel,
      askModel: askModel,
      graphStateFilter: graphStateFilter,
      askFocusNode: $askFocusNode,
      showsAskCard: $showsAskCard,
      whyFileTarget: $whyFileTarget,
      askThreadId: $askThreadId,
      askDraft: $askDraft
    ))
  }
}

