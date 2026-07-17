import SwiftUI
import AtlasCore

/// M0 · Grafo Governado — o mapa vem primeiro.
///
/// Contrato visual: `docs/proposals/atlas-code-mobile.html` (tela M0).
/// Ask seed → AtlasCodeView+Ask.swift
struct AtlasCodeView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var model: AtlasCodeModel
    @State var provenanceModel: AtlasCodeProvenanceModel
    @State var mirrorModel: AtlasCodeMirrorModel
    @State var askModel: AtlasCodeAskModel
    @State var selectedNode: AtlasCodeGraphNode?
    @State var showsHealReceipt = false
    /// A pílula é porta, não formulário. Tocar abre o card de conversa — o mesmo
    /// gesto do commit, que abre a folha acima do grafo.
    @State var showsAskCard = false
    @State var whyFileTarget: WhyFileTarget?
    @Namespace var graphRotor
    /// A conversa deste repositório continua onde parou. Fechar o card não é
    /// encerrar o assunto; é só tirar a folha da frente do mapa.
    @State var askThreadId: ThreadID?
    /// Pergunta semeada por quem abriu o card (a folha do commit semeia o
    /// commit). Vazia = a pílula abrindo pelo caminho normal.
    @State var askDraft = ""
    @State var graphStateFilter: AtlasCodeGraphStateFilter = .all

    init(client: AtlasClient, repo: String = "atlas-server") {
        _model = State(initialValue: AtlasCodeModel(client: client, repo: repo))
        _provenanceModel = State(initialValue: AtlasCodeProvenanceModel(client: client, repo: repo))
        _mirrorModel = State(initialValue: AtlasCodeMirrorModel(client: client, repo: repo))
        _askModel = State(initialValue: AtlasCodeAskModel(client: client, repo: repo))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AtlasTheme.bg.ignoresSafeArea()
            content
            askPill
        }
        .navigationTitle("Grafo")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier(A11yID.codeScreen)
        .accessibilityLabel(spokenCodeScreenLabel())
        .accessibilityHint(Self.codeScreenHint)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text(model.repo)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
        .task { if model.phase == .idle { await model.load() } }
        .task { await mirrorModel.refresh() }
        .atlasCodeSheets(
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
