import SwiftUI
import AtlasCore

// Âncoras visíveis — peel de AtlasCodeView+Anchors.

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
}
