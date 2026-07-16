import Foundation

/// H6 · a pílula pergunta ao grafo.
///
/// O contrato deliberadamente NÃO é uma conversa: não há histórico, papéis nem
/// turnos. Cada resposta é um fato com âncoras — os commits que a sustentam e
/// que o grafo acende atrás do vidro. Chat devolve prosa e deixa o operador
/// traduzir sozinho; aqui a resposta aponta para a topologia.
public struct AtlasCodeAskResponse: Decodable, Equatable, Sendable {
    public static let schemaVersion = "atlas.code.ask.v1"

    public let schemaVersion: String
    public let repo: String
    public let question: String
    public let intent: AtlasCodeAskIntent
    /// Falso quando o Atlas não sabe responder. Ausência de resposta é dita,
    /// nunca preenchida com prosa plausível.
    public let answered: Bool
    public let answer: String
    /// Os commits que a resposta cita — o que acende no grafo.
    public let commits: [String]
    /// Quantas âncoras existem, não quantas couberam. Sem isto a tela só sabe
    /// dizer "há mais", e "12 acesos" ao lado de "22 commits" lê como
    /// contradição em vez de recorte.
    public let commitsTotal: Int
    /// Havia mais âncoras do que cabe numa resposta. Nunca corte silencioso.
    public let truncated: Bool
    public let evidence: [AtlasCodeAskEvidence]
    public let source: String
    /// Só em perguntas sobre mudança: o recorte de tempo que a resposta usou,
    /// para o operador poder conferir contra o próprio git.
    public let window: AtlasCodeAskWindow?
    /// O que o AGENTE lê e o operador não vê: o código cru dos commits.
    ///
    /// Só vem no modo `facts`, e só quando a pergunta pede código (revisar).
    /// Nunca vai para a tela — é o dossiê, não a resposta. Sem ele, "revise os
    /// commits de hoje" entrega hashes e nenhuma linha, e revisar sem ver o
    /// código é opinar com voz de autoridade.
    public let detail: String?

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, repo, question, intent, answered, answer, commits, commitsTotal, truncated, evidence, source, window, detail
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Code ask schema.")
        self.schemaVersion = schemaVersion
        self.repo = try values.decode(String.self, forKey: .repo)
        self.question = try values.decode(String.self, forKey: .question)
        self.intent = try values.decode(AtlasCodeAskIntent.self, forKey: .intent)
        self.answered = try values.decode(Bool.self, forKey: .answered)
        self.answer = try values.decode(String.self, forKey: .answer)
        let commits = try values.decodeIfPresent([String].self, forKey: .commits) ?? []
        self.commits = commits
        self.commitsTotal = try values.decodeIfPresent(Int.self, forKey: .commitsTotal) ?? commits.count
        self.truncated = try values.decodeIfPresent(Bool.self, forKey: .truncated) ?? false
        self.evidence = try values.decodeIfPresent([AtlasCodeAskEvidence].self, forKey: .evidence) ?? []
        self.source = try values.decode(String.self, forKey: .source)
        self.window = try values.decodeIfPresent(AtlasCodeAskWindow.self, forKey: .window)
        self.detail = try values.decodeIfPresent(String.self, forKey: .detail)
    }

    /// Os hashes que a resposta cita, prontos para o grafo comparar.
    public var anchorSet: Set<String> { Set(commits) }

    /// O que a tela diz sobre as âncoras. Quando o recorte existe, ele é dito
    /// com número — "12 de 22" —, porque "há mais" ao lado de "22 commits" lê
    /// como contradição, e corte silencioso lê como "é só isso".
    public var anchorNote: String? {
        guard !commits.isEmpty else { return nil }
        if truncated {
            return "\(commits.count) de \(commitsTotal) acesos no grafo"
        }
        return commits.count == 1 ? "1 commit aceso no grafo" : "\(commits.count) commits acesos no grafo"
    }
}

/// O verbo de quem chama `/code/ask`.
///
/// Existe porque a mesma porta faz duas coisas de naturezas opostas, e
/// confundi-las custa caro: perguntando, "revise os commits de hoje" é ORDEM e
/// manda a frota trabalhar; coletando fato para o agente do card ler, a mesma
/// frase é só o assunto do turno — e despachar 12 agentes por causa dela seria
/// obedecer o que ninguém pediu, duas vezes.
public enum AtlasCodeAskMode: String, Sendable {
    /// Lê o git e pode agir: o verbo é do operador.
    case answer
    /// Leitura pura, para o agente ler antes de responder. Nunca despacha.
    case facts
}

/// A natureza da pergunta. Um intent novo do servidor não derruba a folha:
/// aparece como desconhecido, que é o mesmo caminho do "não sei".
public enum AtlasCodeAskIntent: String, Decodable, Equatable, Sendable {
    case problems, changes, find, unknown
    case whyBranch = "why_branch"
    case whoTouched = "who_touched"
    case reviewBatch = "review_batch"
    case hottest, commit, heals

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = AtlasCodeAskIntent(rawValue: raw) ?? .unknown
    }
}

/// O que a resposta leu para poder afirmar o que afirma.
///
/// Numa exceção, a evidência é a LEI que ela viola — com o documento que a
/// justifica. "Está errado porque sim" é o pior silêncio de uma ferramenta de
/// governança; `canon` é o fim desse silêncio.
public struct AtlasCodeAskEvidence: Decodable, Equatable, Sendable, Identifiable {
    public let kind: String
    public let ref: String
    /// O doc canônico que justifica a regra. Ausente quando a regra ainda não
    /// tem lei escrita — e ausência é dita, não preenchida.
    public let canon: String?
    public let target: String?

    public var id: String { "\(kind):\(ref):\(target ?? "")" }
}

public struct AtlasCodeAskWindow: Decodable, Equatable, Sendable {
    public let kind: String
    public let since: Int
    public let timezone: String
}

/// O que a pílula sugere quando está vazia.
///
/// Não é decoração: uma pílula vazia não ensina o próprio poder, e o operador
/// não tem como adivinhar que pode perguntar. Cada sugestão é uma pergunta que
/// o Atlas SABE responder — prometer o que não se cumpre foi o defeito da
/// primeira versão dela.
public enum AtlasCodeAskSuggestions {
    /// Cada uma é uma pergunta que o Atlas SABE responder — provado no
    /// servidor, onde o roteador mora (`test_every_pill_suggestion_routes_to_a_real_intent`).
    ///
    /// A ordem não é decorativa: é o que o operador quer saber ao abrir a tela,
    /// do mais imediato ao mais reflexivo. Estado primeiro (tem problema?),
    /// depois o dia, depois o esforço, e por fim mandar trabalhar.
    public static let all: [String] = [
        "tem algum problema?",
        "o que mudou hoje?",
        "o que você curou essa semana?",
        "revise os commits de hoje",
    ]
}
