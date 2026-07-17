import SwiftUI
import AtlasCore

/// M0 · Grafo Governado — o mapa vem primeiro.
///
/// Contrato visual: `docs/proposals/atlas-code-mobile.html` (tela M0).
/// Leis aplicadas aqui: mapa primeiro (3), estado por exceção (4), um sinal
/// primário por violação (5), linguagem humana em cima e máquina embaixo do
/// vidro (6), a pílula nunca some (7), autonomia > aprovação (1: só veto).
/// Gramática de cor (AtlasCore): dourado = na main · vermelho = fora ·
/// verde = curado. Cor é estado; autor e tipo já são texto.
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

    struct WhyFileTarget: Identifiable {
        let path: String
        var id: String { path }
    }

    /// As âncoras que EXISTEM nesta janela do grafo.
    ///
    /// A resposta cita commits do repositório inteiro; a tela carrega 200. Um
    /// commit de três meses atrás é âncora legítima e não está aqui. Sem cruzar
    /// os dois, "tem algum problema?" apagava o mapa INTEIRO — todos os 200 nós
    /// esmaecidos, nenhum aceso — enquanto a pílula anunciava "12 acesos no
    /// grafo". A tela apagando tudo e dizendo que acendeu doze.
    ///
    /// Interseção vazia = o mapa não tem nada a mostrar sobre esta resposta, e
    /// então ele não finge: fica inteiro, como estava.
    var visibleAnchors: Set<String> {
        guard askModel.isAnchoring, let nodes = model.graph?.nodes else { return [] }
        return askModel.anchors.intersection(nodes.map(\.hash))
    }

    /// O que a pílula diz sobre o mapa — contado no que ACENDEU.
    ///
    /// Três estados, três frases, nenhuma inventada:
    /// - nada ancorado → convite;
    /// - âncoras acesas → quantas, e quantas a resposta citou ao todo;
    /// - âncoras todas fora desta janela → dizer isso, porque o mapa ficar
    ///   intacto depois de uma resposta que citou commits precisa de
    ///   explicação, senão lê como pergunta ignorada.
    var anchorLegend: String? {
        guard askModel.isAnchoring else { return nil }
        let acesas = visibleAnchors.count
        let citadas = askModel.anchors.count
        if acesas == 0 {
            return citadas == 1
                ? "o commit da resposta está fora desta janela"
                : "os \(citadas) commits da resposta estão fora desta janela"
        }
        if acesas < citadas {
            return "\(acesas) de \(citadas) acesos aqui — o resto está fora desta janela"
        }
        return askModel.anchorNote
    }

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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text(model.repo)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityLabel("repositório \(model.repo)")
            }
        }
        .task { if model.phase == .idle { await model.load() } }
        .task { await mirrorModel.refresh() }
        .sheet(item: $selectedNode) { node in
            AtlasCodeProvenanceSheet(
                client: session.client,
                repo: model.repo,
                node: node,
                state: model.state(for: node),
                ruleId: model.ruleId(for: node),
                ruleCanon: model.ruleCanon(for: node),
                trunk: model.violations?.trunk,
                phase: provenanceModel.phase,
                // A folha do commit era um beco: o operador abre justamente o
                // commit que NÃO entendeu, e ali não havia caminho nenhum para
                // perguntar — a pílula fica atrás da folha, inalcançável. Ele
                // teria de decorar o hash, fechar, abrir o card e digitar.
                //
                // Duas folhas não coexistem no SwiftUI: fechar esta é o que
                // abre aquela. O commit vai junto na pergunta.
                onAsk: {
                    selectedNode = nil
                    // O roteador só reconhece hash com pelo menos um DÍGITO
                    // (senão `decade`/`facade` virariam alvo). Um prefixo de 10
                    // pode ser todo letra — raro, mas a pergunta semeada cairia
                    // em `unknown` em silêncio. Cresce o prefixo até ter dígito.
                    var citado = String(node.hash.prefix(10))
                    var tamanho = 10
                    while !citado.contains(where: \.isNumber), tamanho < node.hash.count {
                        tamanho += 4
                        citado = String(node.hash.prefix(tamanho))
                    }
                    askDraft = "o que o commit \(citado) fez, e por quê?"
                    // O sistema precisa terminar de fechar a primeira folha
                    // antes de a segunda subir; sem o respiro, o iOS engole a
                    // segunda e o toque vira nada.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { showsAskCard = true }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showsHealReceipt) {
            if let heal = model.heal {
                AtlasCodeHealReceiptSheet(heal: heal) { Task { await model.undoLastHeal() } }
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        // O card: uma conversa de verdade sobre ESTE repositório. Não é uma
        // pílula que devolve fato solto — é o agente do Atlas, com toda a
        // memória e o ACOS atrás dele, lendo os fatos que o determinístico
        // coletou do git no mesmo turno. Os fatos impedem invenção; o agente
        // entrega entendimento. Nenhum dos dois sozinho é a ferramenta.
        .sheet(isPresented: $showsAskCard) {
            ConversationView(
                client: session.client,
                threadId: askThreadId,
                title: "Código · \(model.repo)",
                emptyPrompt: "O que você quer saber deste repositório?",
                emptySuggestions: AtlasCodeAskSuggestions.all,
                // Esta tela é inteira sobre um repositório: ela DIZ isso, em vez
                // de deixar o Atlas Decide farejar "commit" na prosa — que, com
                // os fatos prefixados, virou a máquina decidindo por si mesma.
                taskKind: "code",
                workspace: model.repo,
                draft: askDraft,
                turnFacts: { [askModel] question in await askModel.facts(for: question) },
                onThread: { askThreadId = $0 }
            )
            // Abre em MEIA tela, e isto é a tese, não conforto: em `.large` o
            // card tapa o mapa inteiro e o acendimento acontece atrás de um
            // vidro opaco — o operador conversa sobre uma topologia que ele não
            // vê se mexer, e o que sobra é um chat comum sobre git. Em `.medium`
            // o grafo fica atrás e a resposta ACENDE na frente dele, ao vivo.
            // A resposta não é o texto: é o mapa se transformando.
            //
            // `.large` continua ali para quem quer ler uma revisão longa —
            // arrastar para cima é do operador, não meu.
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            // Fundo translúcido: o mapa atrás não pode virar papel de parede
            // preto. Ele é o assunto.
            .presentationBackground(.ultraThinMaterial)
        }
        .sheet(item: $whyFileTarget) { target in
            AtlasCodeWhySheet(client: session.client, repo: model.repo, file: target.path)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

}
