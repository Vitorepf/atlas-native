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
