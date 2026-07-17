import SwiftUI
import AtlasCore

// MARK: - Resumo da operação (C20: digest por agregação de dado REAL)
// Body → AutonomosOperationDigestSection+Body.swift

/// O "resumo ao acordar" da cena 06 — mas honesto: agrega SÓ o que o
/// servidor já publica (entregas comprovadas, pendências por risco,
/// decisões aguardando, incidente). Sem `next_digest_at` inventado — o
/// agendamento formal fica no pedido C20 até o servidor publicar o horário.
struct AutonomosOperationDigestSection: View {
    let deliveredTotal: Int
    let pendingCount: Int
    let inboxCount: Int
    let incidentPresent: Bool
    let oldestBacklogCreatedAt: Date?
    let findingsByRisk: [String: Int]
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        digestBody
    }
}
