import SwiftUI
import AtlasCore

// Âncoras da pílula e alvo do Why — peel de AtlasCodeView (régua ~160).

extension AtlasCodeView {
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
}
