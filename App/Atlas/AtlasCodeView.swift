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
    @Environment(AtlasSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var model: AtlasCodeModel
    @State private var provenanceModel: AtlasCodeProvenanceModel
    @State private var mirrorModel: AtlasCodeMirrorModel
    @State private var askModel: AtlasCodeAskModel
    @State private var selectedNode: AtlasCodeGraphNode?
    @State private var showsHealReceipt = false
    /// A pílula é porta, não formulário. Tocar abre o card de conversa — o mesmo
    /// gesto do commit, que abre a folha acima do grafo.
    @State private var showsAskCard = false
    /// A conversa deste repositório continua onde parou. Fechar o card não é
    /// encerrar o assunto; é só tirar a folha da frente do mapa.
    @State private var askThreadId: String?
    /// Pergunta semeada por quem abriu o card (a folha do commit semeia o
    /// commit). Vazia = a pílula abrindo pelo caminho normal.
    @State private var askDraft = ""

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
    private var visibleAnchors: Set<String> {
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
    private var anchorLegend: String? {
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
    }

    // MARK: - Estados

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .idle, .loading:
            VStack(spacing: 12) {
                ProgressView().tint(AtlasTheme.accent)
                Text("lendo a topologia do repositório…")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            VStack(spacing: 14) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 24))
                    .foregroundStyle(AtlasCodePalette.alert)
                Text("não consegui ler este repositório")
                    .font(AtlasFont.serif(20, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(message)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                Button("Tentar de novo") { Task { await model.load() } }
                    .buttonStyle(.borderedProminent)
                    .tint(AtlasTheme.accent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            if let graph = model.graph, !graph.nodes.isEmpty {
                graphContent(graph)
            } else {
                Text("nenhum commit para mostrar")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - O mapa

    private func graphContent(_ graph: AtlasCodeGraphResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                statusCapsule
                    .padding(.bottom, 14)

                ForEach(Array(graph.nodes.enumerated()), id: \.element.id) { index, node in
                    AtlasCodeCommitRow(
                        node: node,
                        state: model.state(for: node),
                        ruleId: model.ruleId(for: node),
                        trunk: model.violations?.trunk,
                        isFirst: index == 0,
                        isLast: index == graph.nodes.count - 1,
                        // A resposta da pílula acende o que ela cita: o mapa é
                        // que responde. Sem resposta, ninguém está apagado.
                        isDimmed: !visibleAnchors.isEmpty && !visibleAnchors.contains(node.hash)
                    ) {
                        selectedNode = node
                        Task { await provenanceModel.load(hash: node.hash) }
                    }
                }

                // O grafo mostra os N mais recentes e PARA — o repo tem 8.700.
                // `hasMore` chegava no contrato e ninguém lia: a tela cortava a
                // história em silêncio, e corte silencioso lê como "é só isso".
                // Não é paginação (isso é obra); é a confissão do teto.
                if graph.pagination.hasMore {
                    Text("\(graph.nodes.count) commits mais recentes — há mais história")
                        .font(AtlasFont.serifItalic(12))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                        .accessibilityIdentifier("code-graph-truncated")
                }

                if let mirror = mirrorModel.response {
                    AtlasCodeMirrorCard(response: mirror)
                        .padding(.top, 22)
                }

                if model.week != nil || model.hasHealReceipt {
                    weekSection
                        .padding(.top, 22)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 10)
            .padding(.bottom, 96)  // espaço da pílula
        }
    }

    /// Cápsula central e simétrica: a única voz do estado geral.
    ///
    /// TRÊS estados, não dois. O booleano `hasViolations` fazia o falso cobrir
    /// duas coisas opostas — "varri e está são" e "não consegui varrer" —, e a
    /// varredura caindo dava alta em verde com um tique. Cor é ESTADO, e o
    /// estado ali era "não olhei": nem verde nem vermelho, ausência.
    private var statusCapsule: some View {
        let cor: Color = {
            switch model.scanState {
            case .violating: return AtlasCodePalette.alert
            case .clean: return AtlasCodePalette.healed
            case .unknown: return AtlasTheme.textTertiary
            }
        }()
        let simbolo: String = {
            switch model.scanState {
            case .violating: return "exclamationmark.triangle"
            case .clean: return "checkmark"
            // Nem alerta nem tique: interrogação é o que se sabe.
            case .unknown: return "questionmark"
            }
        }()

        return HStack(spacing: 7) {
            Image(systemName: simbolo)
                .font(.system(size: 10, weight: .semibold))
            Text(model.statusHeadline)
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
        }
        .foregroundStyle(cor)
        .padding(.horizontal, 15)
        .padding(.vertical, 7)
        .background(Capsule().fill(cor.opacity(0.09)))
        .overlay(Capsule().strokeBorder(cor.opacity(0.35), lineWidth: 1))
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: model.scanState)
        .accessibilityLabel(model.statusHeadline)
        .accessibilityIdentifier("code-status")
    }

    /// A semana + o recibo da noite: fatos consumados, nunca pedidos.
    private var weekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let week = model.week {
                HStack(alignment: .firstTextBaseline) {
                    Text("A semana")
                        .font(AtlasFont.serif(18, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Spacer()
                    Text(week.window)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                HStack(spacing: 18) {
                    weekMetric("commits", value: week.commits)
                    weekMetric("curas", value: week.heals)
                    weekMetric("prevenidas", value: week.prevented)
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("A semana: \(week.commits) commits, \(week.heals) curas, \(week.prevented) prevenidas")
            }

            if model.hasHealReceipt {
                Button { showsHealReceipt = true } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal")
                            .font(.system(size: 12))
                            .foregroundStyle(AtlasCodePalette.healed)
                        Text("curado sozinho · ver recibo")
                            .font(AtlasFont.serifItalic(13))
                            .foregroundStyle(AtlasTheme.textSecondary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .padding(.vertical, 11)
                    .padding(.horizontal, 13)
                    .background(AtlasCodePalette.healed.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(AtlasCodePalette.healed.opacity(0.3), lineWidth: 1)
                    )
                }
                .accessibilityIdentifier("code-heal-receipt")
            }
        }
    }

    private func weekMetric(_ label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(String(value))
                .font(AtlasFont.serif(21, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }

    /// Lei 7: a pílula nunca some — nem aqui. E agora ela responde.
    ///
    /// Ela não abre outra tela: expande sobre o grafo, que continua visível
    /// atrás (lei 3, o mapa vem primeiro). A resposta acende os commits que
    /// cita — o mapa é que responde, não uma bolha de conversa.
    /// A pílula não responde: ela abre quem responde. Um campo de texto
    /// espremido numa cápsula sobre o grafo prometia conversa e entregava
    /// formulário — e o operador tinha razão em chamar aquilo de burro. O card
    /// tem histórico, agente, orquestra ao vivo e anexo; a cápsula não tinha
    /// nada disso e nunca teria.
    private var askPill: some View {
        HStack(spacing: 9) {
            Text("✦")
                .font(AtlasFont.serif(13))
                .foregroundStyle(AtlasTheme.accent)
            // Ancorado, a pílula deixa de convidar e passa a LEGENDAR: o mapa
            // atrás está recortado, e recorte sem legenda lê como "é só isso".
            //
            // A legenda conta o que ACENDEU, não o que a resposta citou: dizer
            // "12 acesos" com zero acesos na tela é a pílula desmentindo o mapa
            // logo acima dela.
            Text(anchorLegend ?? "pergunte sobre este repositório")
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(anchorLegend != nil ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityIdentifier("code-ask-anchor-note")
            Spacer(minLength: 0)
            if askModel.isAnchoring {
                // A conversa anterior deixou o mapa aceso: dá para apagar sem
                // reabrir o card.
                Button { askModel.clear() } label: {
                    Text("mostrar tudo")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("code-ask-clear")
            }
            Image(systemName: "chevron.up")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(AtlasTheme.separator, lineWidth: 0.5))
        .contentShape(Capsule())
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            // A pílula abre limpa: a pergunta semeada é de quem semeou (a folha
            // do commit), e herdá-la aqui seria a tela pondo palavra na boca do
            // operador que só quis abrir a conversa.
            askDraft = ""
            showsAskCard = true
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.bottom, 10)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Conversar com o Atlas sobre este repositório")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("code-ask-pill")
    }
}

// MARK: - Paleta do domínio (gramática de estado)

enum AtlasCodePalette {
    static let onMain = AtlasTheme.accent          // dourado: a cor da espinha
    static let alert = Color(hex: 0xE08C8C)        // vermelho: fora da main
    static let healed = Color(hex: 0x83B46D)       // verde: curado
    static let history = Color(hex: 0x647682)      // cinza: história alcançável

    static func color(for state: AtlasCodeNodeState) -> Color {
        switch state {
        case .onMain: return onMain
        case .violating: return alert
        case .healed: return healed
        case .history: return history
        }
    }
}

// MARK: - Linha do commit (mensagem é a manchete)

private struct AtlasCodeCommitRow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let node: AtlasCodeGraphNode
    let state: AtlasCodeNodeState
    let ruleId: String?
    /// A trunk real: a lei na linha fala o nome da linha, nunca "main" no chute.
    let trunk: String?
    let isFirst: Bool
    let isLast: Bool
    /// A pílula respondeu e este commit não está na resposta: ele recua, mas
    /// nunca some — esconder história para responder uma pergunta seria mentir
    /// sobre o repositório.
    var isDimmed: Bool = false
    let onTap: () -> Void

    private var color: Color { AtlasCodePalette.color(for: state) }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                spine
                VStack(alignment: .leading, spacing: 4) {
                    // Manchete: a mensagem do commit. Sem mensagem, o hash é o
                    // último recurso honesto — nunca inventamos um título.
                    Text(node.message ?? String(node.hash.prefix(8)))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(state == .violating ? AtlasCodePalette.alert : AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    HStack(spacing: 6) {
                        Text(node.authorName.isEmpty ? node.authorEmail : node.authorName)
                        Text("·")
                        Text(AtlasCodeRelativeTime.short(from: node.authoredAt))
                        if let ruleId {
                            Text("·")
                            // A lei em português. `worktree_allowlist` é nome de
                            // máquina e não sobe à tela em que o operador decide
                            // se apaga trabalho — o tradutor já existia, e só o
                            // grafo continuava falando snake_case.
                            Text(AtlasCodeIssue.law(ruleId, trunk: trunk))
                                .foregroundStyle(AtlasCodePalette.alert)
                        }
                    }
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 7)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(isDimmed ? 0.26 : 1)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.28), value: isDimmed)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        // O leitor de tela precisa do mesmo sinal que o olho recebe.
        .accessibilityHint(isDimmed ? "fora da resposta" : "")
        .accessibilityIdentifier("code-commit-\(node.hash.prefix(8))")
    }

    /// A espinha: linha contínua + o nó. O desvio salta ao olho pela cor.
    private var spine: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(isFirst ? Color.clear : AtlasTheme.accent.opacity(0.55))
                .frame(width: 2, height: 8)
            ZStack {
                if state == .violating {
                    Circle()
                        .strokeBorder(AtlasCodePalette.alert.opacity(0.5), lineWidth: 1.4)
                        .frame(width: 22, height: 22)
                }
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().strokeBorder(AtlasTheme.bg, lineWidth: 2))
            }
            .frame(width: 22, height: 22)
            Rectangle()
                .fill(isLast ? Color.clear : AtlasTheme.accent.opacity(0.55))
                .frame(width: 2)
                .frame(maxHeight: .infinity)
        }
        .frame(width: 22)
        .accessibilityHidden(true)
    }

    private var accessibilityText: String {
        let title = node.message ?? String(node.hash.prefix(8))
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        switch state {
        case .violating: return "\(title), por \(author), fora da main\(ruleId.map { ", regra \($0)" } ?? "")"
        case .healed: return "\(title), por \(author), curado"
        case .onMain: return "\(title), por \(author), na main"
        case .history: return "\(title), por \(author)"
        }
    }
}

enum AtlasCodeRelativeTime {
    /// Tempo relativo curto e humano, a partir do epoch do git.
    static func short(from epoch: Int, now: Date = Date()) -> String {
        let seconds = max(0, Int(now.timeIntervalSince1970) - epoch)
        switch seconds {
        case ..<3600: return "\(max(1, seconds / 60))min"
        case ..<86_400: return "\(seconds / 3600)h"
        case ..<2_592_000: return "\(seconds / 86_400)d"
        default: return "\(seconds / 2_592_000)mês"
        }
    }
}

// MARK: - Folha: por que esta linha existe (C23)

/// A folha responde, em ordem, as perguntas de quem abre um commit: em que
/// estado ele está, o que ele diz, por que existe, e o que ele tocou.
/// O hash fecha a folha — máquina embaixo do vidro (lei 6).
private struct AtlasCodeProvenanceSheet: View {
    let node: AtlasCodeGraphNode
    let state: AtlasCodeNodeState
    let ruleId: String?
    /// O doc que sustenta a acusação. Ausente = a regra ainda não tem lei
    /// escrita, e isso é dito calando — nunca com um caminho plausível.
    let ruleCanon: String?
    /// A trunk real — a lei citada fala o nome da linha, nunca "main" no chute.
    let trunk: String?
    let phase: AtlasCodeProvenanceModel.Phase
    /// A saída do beco: daqui o operador fala com o agente SOBRE este commit.
    let onAsk: () -> Void

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    lawCitation
                    askButton
                    content
                    hashFooter
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(22)
                .padding(.bottom, 12)
            }
        }
    }

    /// A lei que sustenta a acusação — e o documento que a prova.
    ///
    /// Só existe quando há acusação, e é onde a governança se separa da
    /// autoridade sem prova: "está errado porque sim" faz o operador parar de
    /// confiar na cor. O contrato C24 promete `rule_canon_ref` desde o começo e
    /// o servidor o mandava; o app não tinha o campo, e a lei morria no fio.
    ///
    /// Sem o doc (regra do canon que ainda não tem lei escrita), a frase em
    /// português aparece sozinha: ausência dita calando, não preenchida com um
    /// caminho plausível.
    @ViewBuilder
    private var lawCitation: some View {
        if state == .violating, let ruleId {
            VStack(alignment: .leading, spacing: 3) {
                Text(AtlasCodeIssue.law(ruleId, trunk: trunk))
                    .font(AtlasFont.serif(14, .semibold))
                    .foregroundStyle(AtlasCodePalette.alert)
                if let ruleCanon {
                    Text(ruleCanon)
                        .font(AtlasFont.mono(8.5))
                        .foregroundStyle(AtlasTheme.textTertiary.opacity(0.85))
                        .lineLimit(1)
                        .truncationMode(.head)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(AtlasCodePalette.alert.opacity(0.08))
            )
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("code-provenance-law")
        }
    }

    /// A porta para o agente, com o commit já no assunto.
    ///
    /// Fica logo abaixo da manchete, e não no rodapé: quem abre um commit que
    /// não entendeu não deveria ter de rolar a folha inteira — passando pelo
    /// que ele não entendeu — para achar como perguntar.
    private var askButton: some View {
        Button(action: onAsk) {
            HStack(spacing: 8) {
                Text("✦")
                    .font(AtlasFont.serif(12))
                    .foregroundStyle(AtlasTheme.accent)
                Text("perguntar sobre este commit")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(AtlasTheme.separator, lineWidth: 0.5))
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("code-provenance-ask")
        .accessibilityLabel("Perguntar ao Atlas sobre este commit")
    }

    // MARK: Cabeçalho — estado, manchete, dateline

    private var header: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 6) {
                Circle()
                    .fill(AtlasCodePalette.color(for: state))
                    .frame(width: 6, height: 6)
                Text(stateLabel)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.4)
                    .foregroundStyle(AtlasCodePalette.color(for: state))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(stateLabel.lowercased())
            .accessibilityIdentifier("code-provenance-state")

            Text(node.message ?? "Por que esta linha existe")
                .font(AtlasFont.serif(22, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 3) {
                Text(dateline)
                    .font(AtlasFont.mono(9.5))
                    .foregroundStyle(AtlasTheme.textTertiary)
                // A magnitude do commit vem cedo: uma descrição longa não pode
                // esconder o tamanho do que ele fez. A lista fica no fim.
                if case .loaded(let provenance) = phase, let headline = provenance.diffHeadline {
                    Text(headline)
                        .font(AtlasFont.mono(9.5))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stateLabel: String {
        switch state {
        case .onMain: return "NA MAIN"
        // A lei em português e em caixa alta de manchete — nunca o id cru:
        // "FORA DA MAIN · WORKTREE_ALLOWLIST" era metade português, metade
        // banco de dados.
        case .violating: return ruleId.map { "FORA DA LINHA · \(AtlasCodeIssue.law($0, trunk: trunk).uppercased())" } ?? "FORA DA LINHA"
        case .healed: return "CURADO"
        case .history: return "HISTÓRIA"
        }
    }

    /// Autor · agente · quando. O agente só aparece quando o ledger respondeu.
    private var dateline: String {
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        var parts = [author]
        if case .loaded(let provenance) = phase { parts.append(provenance.agentLabel) }
        parts.append("há \(AtlasCodeRelativeTime.short(from: node.authoredAt))")
        return parts.joined(separator: " · ")
    }

    private var hashFooter: some View {
        Text(node.hash)
            .font(AtlasFont.mono(9))
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
            .textSelection(.enabled)
            .padding(.top, 2)
            .accessibilityLabel("hash do commit")
    }

    // MARK: Corpo

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .idle, .loading:
            HStack(spacing: 10) {
                ProgressView().tint(AtlasTheme.accent)
                Text("lendo o ledger…")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.top, 2)
        case .failed(let message):
            VStack(alignment: .leading, spacing: 6) {
                Text("não consegui ler a proveniência")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textSecondary)
                Text(message)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasCodePalette.alert)
            }
        case .loaded(let provenance):
            VStack(alignment: .leading, spacing: 18) {
                // A descrição que o autor escreveu — o raciocínio, não o rótulo.
                // O corpo vem quebrado para o terminal; aqui ele volta a ser prosa.
                if let body = provenance.commitBody {
                    Text(AtlasCodeCommitBody.prose(body))
                        .font(AtlasFont.serif(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("code-commit-body")
                }

                // A frase do operador: o que só o Atlas sabe, porque só o Atlas
                // guarda o ledger. Ausência é dita, nunca preenchida.
                if let quote = provenance.operatorQuote {
                    pullQuote(quote)
                }

                if let gates = provenance.gates, !gates.isEmpty {
                    block("Prova no ledger") { AtlasCodeChipRow(items: gates) }
                }
                if let obra = provenance.obra, !obra.isEmpty {
                    block("Obra") { AtlasCodeChipRow(items: obra) }
                }

                filesSection(provenance)
            }
        }
    }

    private func pullQuote(_ quote: String) -> some View {
        HStack(alignment: .top, spacing: 11) {
            Rectangle()
                .fill(AtlasTheme.accent.opacity(0.55))
                .frame(width: 2)
            VStack(alignment: .leading, spacing: 5) {
                Text("\u{201C}\(quote)\u{201D}")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("sua frase")
                    .font(.system(size: 9))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityLabel("sua frase: \(quote)")
    }

    /// O que o commit tocou — no fim, onde o olho procura depois de entender.
    private func filesSection(_ provenance: AtlasCodeProvenance) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("ARQUIVOS")
                .font(.system(size: 8.5, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(AtlasTheme.textTertiary)

            if provenance.files.isEmpty {
                // Merge ou commit vazio: o Git não mediu diff direto.
                Text("nenhum arquivo mudou neste commit")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textTertiary)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(provenance.files.enumerated()), id: \.element.id) { index, file in
                        if index > 0 {
                            Divider().overlay(AtlasTheme.separator.opacity(0.5))
                        }
                        AtlasCodeFileRow(file: file)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .accessibilityIdentifier("code-commit-files")
    }

    private func block(_ title: String, @ViewBuilder body: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title.uppercased())
                .font(.system(size: 8.5, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(AtlasTheme.textTertiary)
            body()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
    }
}

/// Uma linha por arquivo. O VERBO é a forma do símbolo, não a cor: cor aqui
/// é reservada ao estado do commit (main/fora/curado) e mentiria se pintasse
/// tipo de mudança de vermelho dentro de um commit saudável.
private struct AtlasCodeFileRow: View {
    let file: AtlasCodeFileChange

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 8.5, weight: .bold))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 17, height: 17)
                .background(AtlasTheme.surfaceHi, in: RoundedRectangle(cornerRadius: 5))

            VStack(alignment: .leading, spacing: 1) {
                Text(file.fileName)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                if let subtitle {
                    Text(subtitle)
                        .font(AtlasFont.mono(8.5))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1)
                        .truncationMode(.head)
                }
            }

            Spacer(minLength: 8)

            if let additions = file.additions, let deletions = file.deletions {
                Text("+\(additions) \u{2212}\(deletions)")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
            } else {
                // Binário: o Git não conta linhas — e o Atlas não inventa.
                Text("binário")
                    .font(AtlasFont.mono(8.5))
                    .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
            }
        }
        .padding(.vertical, 9)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private var subtitle: String? {
        if let from = file.renamedFrom { return "de \(from)" }
        return file.directory
    }

    private var symbol: String {
        switch file.status {
        case .added: return "plus"
        case .modified: return "pencil"
        case .deleted: return "minus"
        case .renamed: return "arrow.right"
        case .copied: return "doc.on.doc"
        case .typeChanged: return "arrow.triangle.2.circlepath"
        case .unknown: return "questionmark"
        }
    }

    private var verb: String {
        switch file.status {
        case .added: return "adicionado"
        case .modified: return "alterado"
        case .deleted: return "removido"
        case .renamed: return "renomeado"
        case .copied: return "copiado"
        case .typeChanged: return "tipo alterado"
        case .unknown: return "mudança desconhecida"
        }
    }

    private var accessibilityText: String {
        var text = "\(file.path), \(verb)"
        if let from = file.renamedFrom { text += ", de \(from)" }
        if let additions = file.additions, let deletions = file.deletions {
            text += ", \(additions) linhas adicionadas, \(deletions) removidas"
        } else {
            text += ", arquivo binário"
        }
        return text
    }
}

private struct AtlasCodeChipRow: View {
    let items: [String]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasCodePalette.healed)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay(
                        Capsule().strokeBorder(AtlasCodePalette.healed.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Folha: Recibo de Cura (C25 — fato consumado, só veto)

private struct AtlasCodeHealReceiptSheet: View {
    let heal: AtlasCodeHealResponse
    let onUndo: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 7) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                    Text("CURADO SOZINHO · \(heal.mode.uppercased())")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.2)
                }
                .foregroundStyle(AtlasCodePalette.healed)

                Text("você não foi necessário")
                    .font(AtlasFont.serif(20, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(heal.stepReceipts) { receipt in
                        HStack(alignment: .top, spacing: 9) {
                            Image(systemName: receipt.status == "completed" ? "checkmark" : "xmark")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(receipt.status == "completed" ? AtlasCodePalette.healed : AtlasCodePalette.alert)
                                .padding(.top, 2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(receipt.action)
                                    .font(.system(size: 13))
                                    .foregroundStyle(AtlasTheme.textPrimary)
                                Text(receipt.result)
                                    .font(AtlasFont.mono(9))
                                    .foregroundStyle(AtlasTheme.textTertiary)
                            }
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))

                // Único verbo humano: o veto retroativo. Nunca "Aprovar".
                //
                // E ele tem PRAZO: o servidor grava `undo_expires_at` em todo
                // recibo (30 dias) e recusa de verdade depois. A tela nunca lia
                // o campo — o botão continuava convidativo e o toque falhava,
                // então o operador descobria que perdeu o direito no momento em
                // que tentava exercê-lo. Numa tela cujo poder humano é esse e
                // só esse, prazo invisível é poder retirado em silêncio.
                if let note = AtlasCodeUndoWindow.note(expiresAt: heal.stepReceipts.first?.undoExpiresAt) {
                    Text(note)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityIdentifier("code-heal-undo-window")
                }
                if heal.healId != nil, AtlasCodeUndoWindow.isOpen(expiresAt: heal.stepReceipts.first?.undoExpiresAt) {
                    Button {
                        onUndo()
                        dismiss()
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "arrow.uturn.backward")
                            Text("Desfazer — com recibo")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .background(AtlasTheme.surface, in: RoundedRectangle(cornerRadius: 13))
                        .overlay(
                            RoundedRectangle(cornerRadius: 13)
                                .strokeBorder(AtlasTheme.separator, lineWidth: 0.5)
                        )
                    }
                    .accessibilityIdentifier("code-heal-undo")
                }
                Spacer(minLength: 0)
            }
            .padding(22)
        }
    }
}
