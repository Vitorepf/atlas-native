import Foundation

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
