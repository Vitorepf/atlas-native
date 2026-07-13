import Foundation
#if canImport(ActivityKit)
import ActivityKit

// Contrato da Live Activity do turno — COMPARTILHADO app ↔ widget extension
// (o project.yml inclui este arquivo nos dois alvos). O estado é a projeção
// mínima do cockpit: o que o Atlas está fazendo agora + desde quando.
struct AtlasTurnAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// Atividade atual (do contrato C5: "planejando", "executando…") ou
        /// estado terminal ("resposta pronta").
        var phaseTitle: String
        /// Início do turno — o timer da lock screen conta a partir daqui.
        var startedAt: Date
        /// true quando o turno terminou (muda o glifo e encerra o timer).
        var finished: Bool
    }

    /// Título da conversa — fixo pela vida da activity.
    var threadTitle: String
}
#endif
