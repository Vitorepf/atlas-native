import Foundation

/// H6 · a síntese: o determinístico COLETA, o agente ENTENDE.
///
/// A pílula sozinha responde rápido e nunca mente, mas só sabe seis perguntas.
/// O agente sozinho entende qualquer pergunta, mas não enxerga o git e inventa
/// commit que não existe. Nenhum dos dois é a ferramenta; a ferramenta é o par.
///
/// Este bloco é o contrato entre eles: fatos lidos do git AGORA, prefixados à
/// pergunta do operador no fio. O operador nunca vê este texto — a bolha dele
/// continua sendo exatamente o que ele escreveu (mesma lei do `AtlasLongMessage`).
/// Os fatos impedem invenção; o agente entrega entendimento.
public enum AtlasCodeFacts {
    /// O bloco que precede a pergunta, ou `nil` quando o determinístico não tem
    /// fato nenhum a oferecer.
    ///
    /// `nil` é resposta legítima e comum: "esse commit foi uma boa ideia?" não é
    /// filtro de git, é julgamento — o agente responde sem muleta. Fato falso
    /// seria pior que fato ausente, então ausência não vira prosa plausível.
    public static func block(from response: AtlasCodeAskResponse) -> String? {
        guard response.answered else { return nil }
        let answer = response.answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !answer.isEmpty else { return nil }

        var lines: [String] = [
            "[Fatos lidos do git de \(response.repo) agora, por leitura direta do repositório. São verdade. Não os contradiga e não invente commit, arquivo ou data além destes.]",
            answer,
        ]

        if !response.commits.isEmpty {
            let shown = response.commits.prefix(commitCeiling)
            // O recorte é dito com número: "12 de 43" é recorte; "12" ao lado de
            // "43 commits" na frase acima leria como contradição.
            let scope = response.commits.count > shown.count || response.truncated
                ? " (\(shown.count) de \(response.commitsTotal))"
                : ""
            lines.append("Commits que sustentam isto\(scope): " + shown.joined(separator: " "))
        }

        let laws = response.evidence.compactMap(lawLine).prefix(evidenceCeiling)
        if !laws.isEmpty {
            lines.append("Leis do Atlas em jogo:")
            lines.append(contentsOf: laws)
        }

        // O código vem por último e inteiro: é o que o agente precisa LER para
        // ter veredito em vez de opinião. O servidor já disse ali dentro o que
        // não coube — a casca não recorta de novo, ou o aviso viraria mentira.
        if let detail = response.detail?.trimmingCharacters(in: .whitespacesAndNewlines), !detail.isEmpty {
            lines.append("")
            lines.append(detail)
        }

        return lines.joined(separator: "\n")
    }

    /// Uma lei por linha: o que ela é, onde ela dói, e o documento que a
    /// sustenta. Sem o canon, o agente só sabe dizer "está errado porque sim" —
    /// que é o pior silêncio de uma ferramenta de governança.
    private static func lawLine(_ evidence: AtlasCodeAskEvidence) -> String? {
        guard evidence.kind == "rule" || evidence.kind == "violation" else { return nil }
        var line = "- \(evidence.ref)"
        if let target = evidence.target, !target.isEmpty { line += " → \(target)" }
        if let canon = evidence.canon, !canon.isEmpty { line += " (canon: \(canon))" }
        return line
    }

    /// Tetos de fio, não de verdade: o `input_text` do servidor não é lugar de
    /// carregar um repositório inteiro. O número total continua na frase.
    private static let commitCeiling = 12
    private static let evidenceCeiling = 8
}
