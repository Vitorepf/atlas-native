import Foundation

/// O corpo do commit foi escrito para o terminal: quebrado à mão em ~72
/// colunas. Renderizar essas quebras cruas numa fonte proporcional parte
/// frases no ar — foi o que a folha fez na primeira prova.
///
/// Aqui o texto volta a ser prosa: parágrafos (separados por linha em branco)
/// são refluídos numa linha só; linhas que carregam forma própria — listas,
/// numeração, código indentado — mantêm a quebra, porque nelas a quebra é
/// significado, não acidente do terminal.
///
/// Trailers (`Co-Authored-By:`, `Signed-off-by:`) saem: são encanamento do Git
/// e, quando nomeiam o provider, são exatamente o detalhe de motor que não
/// pertence à superfície. Quem assinou já está na dateline.
public enum AtlasCodeCommitBody {
    public static func prose(_ body: String) -> String {
        let lines = body
            .replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "\n")

        var blocks: [String] = []
        var paragraph: [String] = []

        func flush() {
            if !paragraph.isEmpty {
                blocks.append(paragraph.joined(separator: " "))
                paragraph = []
            }
        }

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty {
                flush()

                continue
            }

            if isTrailer(trimmed) {
                flush()

                continue
            }

            if keepsItsOwnShape(line) {
                flush()
                blocks.append(trimmed)

                continue
            }

            paragraph.append(trimmed)
        }
        flush()

        return blocks.joined(separator: "\n\n")
    }

    /// Trailer do Git: chave-sem-espaço seguida de dois-pontos e valor.
    private static func isTrailer(_ trimmed: String) -> Bool {
        let known = ["co-authored-by", "signed-off-by", "reviewed-by", "acked-by", "tested-by", "cc", "refs", "closes", "fixes"]
        guard let colon = trimmed.firstIndex(of: ":") else { return false }
        let key = trimmed[trimmed.startIndex..<colon].lowercased()

        return known.contains(key)
    }

    /// A linha desenha a si mesma? Então a quebra dela é intencional.
    private static func keepsItsOwnShape(_ line: String) -> Bool {
        // Código ou citação indentada: o recuo é a forma.
        if line.hasPrefix("    ") || line.hasPrefix("\t") { return true }

        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // Marcador de lista, citação ou título.
        if let first = trimmed.first, "-*•>#".contains(first) {
            // "—" de travessão abre prosa, não lista; só o hífen ASCII marca item.
            return trimmed.count > 1 && trimmed.dropFirst().first == " " || first == "#"
        }

        // Item numerado: "1. " ou "2) ".
        if let match = trimmed.range(of: #"^\d+[.)]\s"#, options: .regularExpression), match.lowerBound == trimmed.startIndex {
            return true
        }

        return false
    }
}
