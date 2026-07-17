import Foundation

/// The color grammar of the graph, stated once so the shell never invents it.
/// Color encodes STATE, never author or commit type — those are already text.
public enum AtlasCodeNodeState: String, Equatable, Sendable {
    /// On the default branch: the norm, the color of the spine.
    case onMain
    /// Off the default branch and flagged by a rule: the exception.
    case violating
    /// Healed by Atlas: the return to main.
    case healed
    /// Reachable history that is neither the spine nor an exception.
    case history
}

public enum AtlasCodeGraphState {
    /// Quem está na espinha: tudo que a ponta da main alcança pelos pais.
    ///
    /// A ref NÃO é a resposta, e essa foi a falha mais estrutural da tela: o
    /// git decora só a PONTA de cada branch, então `refs` traz "HEAD -> main"
    /// em um nó e vazio nos ancestrais. Medido contra o git real do
    /// atlas-server: dos 200 commits da janela, **197 estão na main e a tela
    /// pintava 6** de dourado. A lei central — dourado = na main — pintava 3%
    /// do que devia, e o resto da espinha aparecia como história cinza, como
    /// se fosse trabalho fora da linha.
    ///
    /// Estar na main é alcançabilidade, não decoração: é uma travessia dos
    /// pais a partir do `head`. Os dois dados já chegam no fio (`head` e
    /// `parents`) e estavam ali, decodificados, sem ninguém usar.
    ///
    /// Uma passada, `Set` de visitados: merge não faz o caminho explodir.
    public static func spine(nodes: [AtlasCodeGraphNode], head: String?) -> Set<String> {
        guard let head, !head.isEmpty else { return [] }

        let parentsOf = Dictionary(nodes.map { ($0.hash, $0.parents) }, uniquingKeysWith: { primeiro, _ in primeiro })
        var naEspinha: Set<String> = []
        var fila = [head]

        while let hash = fila.popLast() {
            guard naEspinha.insert(hash).inserted else { continue }
            // Pai fora da janela é normal (o grafo é paginado) e simplesmente
            // não tem nó para pintar: a travessia para ali, sem drama.
            fila.append(contentsOf: parentsOf[hash] ?? [])
        }

        return naEspinha
    }

    /// Pure resolution used by the shell and by the checks.
    /// Precedence: healed > violating > onMain > history.
    ///
    /// `spineHashes` vem de `spine(nodes:head:)`, calculado UMA vez para o
    /// grafo inteiro — não por nó. Vazio (sem `head` no contrato antigo) faz a
    /// tela cair na ref, que é o comportamento de antes: pinta menos do que
    /// devia, mas nunca pinta de dourado o que não está na main. Errar para o
    /// lado de não afirmar.
    public static func state(
        for node: AtlasCodeGraphNode,
        defaultBranch: String?,
        violatingHashes: Set<String>,
        healedHashes: Set<String>,
        spineHashes: Set<String> = []
    ) -> AtlasCodeNodeState {
        if healedHashes.contains(node.hash) { return .healed }
        if violatingHashes.contains(node.hash) { return .violating }
        if spineHashes.contains(node.hash) { return .onMain }
        if spineHashes.isEmpty, node.isOnDefaultBranch(defaultBranch) { return .onMain }
        return .history
    }
}

/// The canonical fork/merge geometry from the Atlas Código spec.
public enum AtlasCodeGraphGeometry {
    public static func midpointPath(fromX: Double, fromY: Double, toX: Double, toY: Double) -> String {
        let midpoint = (fromY + toY) / 2
        return "M \(fromX),\(fromY) C \(fromX),\(midpoint) \(toX),\(midpoint) \(toX),\(toY)"
    }

    public static func laneX(index: Int, base: Double = 24, step: Double = 32) -> Double {
        base + Double(max(0, index)) * step
    }
}

/// O estado geral da varredura — a gramática da cápsula.
///
/// Três estados, não dois. `hasViolations` era booleano, e o falso cobria duas
/// coisas opostas: "varri e está são" e "NÃO CONSEGUI VARRER". A tela dava alta
/// em verde com um tique quando a varredura caía — cor é ESTADO, e o estado ali
/// era "não olhei". Boa notícia é o que o operador quer ouvir; por isso mentira
/// verde é a mais cara de todas.
public enum AtlasCodeScanState: String, Equatable, Sendable {
    /// Varreu e achou exceção. Vermelho.
    case violating
    /// Varreu e não há exceção. Verde — a única alta legítima.
    case clean
    /// Não varreu (rede, 500, timeout). Nem verde nem vermelho: ausência.
    case unknown
}
