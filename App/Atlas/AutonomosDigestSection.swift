import SwiftUI
import AtlasCore

// MARK: - Próximo / último resumo (M09)

struct AutonomosNextDigestSection: View {
    let digest: AtlasAutonomosDigestResponse

    var body: some View {
        if shouldShowDigest(digest) {
            VStack(alignment: .leading, spacing: 10) {
                AutonomosChrome.sectionCaption(sectionTitle)
                if let next = digest.nextDigestAt?.nonEmpty {
                    Text(next)
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .textSelection(.enabled)
                        .accessibilityLabel("próximo digest agendado para \(next)")
                } else if hasLastDigest(digest) {
                    Text("sem agenda publicada — último resumo abaixo")
                        .font(AtlasFont.serifItalic(14))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else if let reason = digest.schedule.reason?.nonEmpty {
                    Text(reason)
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if hasLastDigest(digest) {
                    lastDigestBody(digest)
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.goldBorder, lineWidth: 1))
            .accessibilityIdentifier(A11yID.autonomosDigestSection)
        } else {
            AutonomosDigestEmptyState()
        }
    }

    private var sectionTitle: String {
        digest.nextDigestAt?.nonEmpty != nil ? "PRÓXIMO RESUMO" : "RESUMO GOVERNADO"
    }

    @ViewBuilder
    private func lastDigestBody(_ digest: AtlasAutonomosDigestResponse) -> some View {
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

    private func shouldShowDigest(_ digest: AtlasAutonomosDigestResponse) -> Bool {
        digest.nextDigestAt?.nonEmpty != nil
            || hasLastDigest(digest)
            || digest.schedule.reason?.nonEmpty != nil
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
        } else {
            VStack(alignment: .leading, spacing: 6) {
                AutonomosChrome.sectionCaption("operação")
                Text("Quieta nesta janela — nenhuma entrega, pendência nem incidente publicado.")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("operação quieta, nenhuma entrega pendência ou incidente")
            .accessibilityIdentifier(A11yID.autonomosOperationQuiet)
        }
    }

    private func digestHeadline(delivered: Int, pending: Int, incident: Bool) -> String {
        if incident { return "Um incidente aguarda sua decisão; o resto da frota segue por exceção." }
        if delivered > 0 && pending == 0 {
            return "\(delivered) entrega\(delivered == 1 ? "" : "s") comprovada\(delivered == 1 ? "" : "s") — silêncio; nada pendente para você."
        }
        if delivered > 0 {
            return "\(delivered) entregue\(delivered == 1 ? "" : "s"), \(pending) ainda na fila — segue sem portão; só exceção te chama."
        }
        return "\(pending) tarefa\(pending == 1 ? "" : "s") na fila; nenhuma entrega comprovada ainda nesta janela."
    }
}

/// Digest carregado mas sem agenda nem último resumo — honesto, não inventa horário.
struct AutonomosDigestEmptyState: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AutonomosChrome.sectionCaption("resumo")
            Text("Digest ainda não agendado pelo servidor — sem next_digest_at neste recorte.")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .atlasCard(cornerRadius: 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("digest não agendado pelo servidor")
        .accessibilityIdentifier(A11yID.autonomosDigestEmpty)
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
