import SwiftUI
import AtlasCore

// Legenda da pílula — peel de AtlasCodeView+Anchors.
// Visible → AtlasCodeView+AnchorsVisible.swift

extension AtlasCodeView {
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
