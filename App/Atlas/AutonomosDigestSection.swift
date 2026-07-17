import SwiftUI
import AtlasCore

// MARK: - Próximo resumo (M09)

struct AutonomosNextDigestSection: View {
    let digest: AtlasAutonomosDigestResponse

    var body: some View {
        if shouldShowDigest(digest) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    AutonomosChrome.sectionCaption("PRÓXIMO RESUMO")
                    Spacer()
                    Text(digest.nextDigestAt ?? "sem digest agendado")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(digest.nextDigestAt == nil ? AtlasTheme.textTertiary : AtlasTheme.accent)
                        .lineLimit(1)
                }
                if let next = digest.nextDigestAt {
                    Text(next)
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .textSelection(.enabled)
                } else {
                    Text(digest.schedule.reason?.nonEmpty ?? "sem digest agendado")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if hasLastDigest(digest) {
                    HStack(spacing: 8) {
                        if digest.last.counts.delivered > 0 {
                            AutonomosChrome.digestChip("\(digest.last.counts.delivered)", "entregas")
                        }
                        if digest.last.counts.risks > 0 {
                            AutonomosChrome.digestChip("\(digest.last.counts.risks)", "riscos")
                        }
                        if digest.last.counts.pendingDecisions > 0 {
                            AutonomosChrome.digestChip("\(digest.last.counts.pendingDecisions)", "decisões")
                        }
                    }
                    if let delivered = digest.last.delivered.first {
                        AutonomosChrome.tag("merge \(String(delivered.mergeHash.prefix(8)))")
                    }
                    if let risk = digest.last.risks.first {
                        Text(risk.title?.nonEmpty ?? risk.reason?.nonEmpty ?? risk.severity)
                            .font(.caption)
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .lineLimit(2)
                    }
                    if let decision = digest.last.pendingDecisions.first {
                        Text(decision.title)
                            .font(.caption)
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.goldBorder, lineWidth: 1))
        }
    }

    private func shouldShowDigest(_ digest: AtlasAutonomosDigestResponse) -> Bool {
        digest.nextDigestAt != nil
            || digest.schedule.available
            || digest.schedule.reason?.nonEmpty != nil
            || hasLastDigest(digest)
    }

    private func hasLastDigest(_ digest: AtlasAutonomosDigestResponse) -> Bool {
        digest.last.counts.delivered > 0
            || digest.last.counts.risks > 0
            || digest.last.counts.pendingDecisions > 0
            || !digest.last.delivered.isEmpty
            || !digest.last.risks.isEmpty
            || !digest.last.pendingDecisions.isEmpty
    }
}

// MARK: - Resumo da operação (C20: digest por agregação de dado REAL)

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

    var body: some View {
        let hasSignal = deliveredTotal > 0 || pendingCount > 0 || inboxCount > 0 || incidentPresent
        if hasSignal {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    AutonomosChrome.sectionCaption("RESUMO DA OPERAÇÃO")
                    Spacer()
                    Text(incidentPresent ? "requer você" : "por exceção")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(incidentPresent ? AtlasTheme.domOperacional : AtlasTheme.domAutonomos)
                }
                // A frase-título: o estado da frota em uma linha honesta.
                Text(digestHeadline(delivered: deliveredTotal, pending: pendingCount, incident: incidentPresent))
                    .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 8) {
                    if deliveredTotal > 0 { AutonomosChrome.digestChip("\(deliveredTotal)", "entregues · merge") }
                    if pendingCount > 0 { AutonomosChrome.digestChip("\(pendingCount)", "tarefas na fila") }
                    if inboxCount > 0 { AutonomosChrome.digestChip("\(inboxCount)", "decisões aguardam") }
                }
                if let oldest = oldestBacklogCreatedAt {
                    Text("item mais antigo · \(AutonomosChrome.relativeAge(from: oldest))")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.domOperacional)
                        .monospacedDigit()
                }
                if !findingsByRisk.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(findingsByRisk.sorted(by: { $0.value > $1.value }), id: \.key) { risk, n in
                            AutonomosChrome.tag("\(risk): \(n)")
                        }
                    }
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .stroke(incidentPresent ? AtlasTheme.domOperacional.opacity(0.4) : AtlasTheme.goldBorder, lineWidth: 1))
        }
    }

    private func digestHeadline(delivered: Int, pending: Int, incident: Bool) -> String {
        if incident { return "Um incidente aguarda sua decisão; o resto da frota segue por exceção." }
        // delivered>0 = sucesso/silêncio: operação não pede portão humano.
        if delivered > 0 && pending == 0 {
            return "\(delivered) entrega\(delivered == 1 ? "" : "s") comprovada\(delivered == 1 ? "" : "s") — silêncio; nada pendente para você."
        }
        if delivered > 0 {
            return "\(delivered) entregue\(delivered == 1 ? "" : "s"), \(pending) ainda na fila — segue sem portão; só exceção te chama."
        }
        return "\(pending) tarefa\(pending == 1 ? "" : "s") na fila; nenhuma entrega comprovada ainda nesta janela."
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
