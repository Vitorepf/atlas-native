import SwiftUI
import AtlasCore

// Legenda da pílula — peel de AtlasCodeView+Anchors.
// Visible → AtlasCodeView+AnchorsVisible.swift
// Partial → AtlasCodeView+AnchorsPartial.swift

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
        if let focus = askFocusNode {
            return swipeFocusLegend(focus)
        }
        guard askModel.isAnchoring else { return nil }
        let acesas = visibleAnchors.count
        let citadas = askModel.anchors.count
        if acesas < citadas {
            return anchorLegendPartial(acesas: acesas, citadas: citadas)
        }
        return askModel.anchorNote
    }
}
