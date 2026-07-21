import AtlasCore
import SwiftUI

// Cycle 040 fuse → AtlasCodeView+Sheets.swift

// Folhas ask/why do grafo.
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

// Folhas do grafo: entry, bind, modifier, proveniência, heal.
// Zero mudança de rota.

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

extension AtlasCodeView {
    func codeSheetsBind<Content: View>(_ content: Content) -> some View {
        content.atlasCodeSheets(
            session: session,
            model: model,
            provenanceModel: provenanceModel,
            askModel: askModel,
            selectedNode: $selectedNode,
            showsHealReceipt: $showsHealReceipt,
            showsAskCard: $showsAskCard,
            whyFileTarget: $whyFileTarget,
            askThreadId: $askThreadId,
            askDraft: $askDraft,
            onProvenanceAsk: openAskFromProvenance
        )
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
        askWhySheetsBind(provenanceAndHealSheets(on: content))
    }

    func askWhySheetsBind<Content: View>(_ content: Content) -> some View {
        content.modifier(AtlasCodeAskWhySheetsModifier(
            session: session,
            model: model,
            askModel: askModel,
            showsAskCard: $showsAskCard,
            whyFileTarget: $whyFileTarget,
            askThreadId: $askThreadId,
            askDraft: $askDraft
        ))
    }

    @ViewBuilder
    func provenanceAndHealSheets<Content: View>(on content: Content) -> some View {
        healReceiptSheet(on: provenanceSheetBind(on: content))
    }

    @ViewBuilder
    func provenanceSheetBind<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $selectedNode) { node in
                provenanceSheetPresent(provenanceSheetContent(for: node))
            }
    }

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

    func provenanceSheetPresent<Content: View>(_ sheet: Content) -> some View {
        sheet
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    func healReceiptSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showsHealReceipt) {
                if let heal = model.heal {
                    AtlasCodeHealReceiptSheet(heal: heal) { Task { await model.undoLastHeal() } }
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            }
    }
}
