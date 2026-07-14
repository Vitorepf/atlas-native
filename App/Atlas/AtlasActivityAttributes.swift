import Foundation
#if canImport(ActivityKit)
import ActivityKit

// Contrato da Live Activity do turno — COMPARTILHADO app ↔ widget extension
// (o project.yml inclui este arquivo nos dois alvos). O estado é a projeção
// mínima do cockpit: o que o Atlas está fazendo agora + desde quando + quantas
// sessões vivem em paralelo (paridade Cursor: cada sessão é um card na lock
// screen com o próprio timer; o contador aparece quando há mais de uma).
struct AtlasTurnAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// Atividade atual (do contrato C5: "planejando", "executando…") ou
        /// estado terminal ("resposta pronta").
        var phaseTitle: String
        /// Início DESTE turno — o timer da lock screen conta a partir daqui.
        var startedAt: Date
        /// true quando o turno terminou (muda o glifo, congela o timer).
        var finished: Bool
        /// Quantas sessões estão executando em paralelo AGORA (inclui esta).
        /// 1 = não exibe contador; >1 = "× N" na ilha e "· N sessões" no card.
        var activeSessions: Int
        /// C14 (aditivo/opcional — payload APNs antigo segue decodando):
        /// pausa confirmada pelo servidor; true → o widget congela
        /// `pausedDisplay` em vez de rodar o timer. Espera NÃO conta tempo.
        var paused: Bool? = nil
        /// Tempo ATIVO acumulado formatado ("m:ss"), congelado na pausa/fim.
        var pausedDisplay: String? = nil
    }

    /// Título da conversa — fixo pela vida da activity.
    var threadTitle: String
    /// Chave estável do turno (thread id) — liga a activity ao model dono.
    var threadKey: String
}
#endif
