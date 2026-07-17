import SwiftUI
import AtlasCore

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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                        .accessibilityHidden(true)
                }
                Text(AutonomosOperationDigestA11y.displayHeadline(
                    delivered: deliveredTotal, pending: pendingCount, incident: incidentPresent))
                    .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityHidden(true)
                HStack(spacing: 8) {
                    if deliveredTotal > 0 { AutonomosChrome.digestChip("\(deliveredTotal)", "entregues · merge") }
                    if pendingCount > 0 { AutonomosChrome.digestChip("\(pendingCount)", "tarefas na fila") }
                    if inboxCount > 0 { AutonomosChrome.digestChip("\(inboxCount)", "decisões aguardam") }
                }
                .accessibilityHidden(true)
                .animation(reduceMotion ? nil : .default, value: deliveredTotal)
                .animation(reduceMotion ? nil : .default, value: pendingCount)
                .animation(reduceMotion ? nil : .default, value: inboxCount)
                if let oldest = oldestBacklogCreatedAt {
                    Text("item mais antigo · \(AutonomosChrome.relativeAge(from: oldest))")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.domOperacional)
                        .monospacedDigit()
                        .accessibilityHidden(true)
                }
                if !findingsByRisk.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(findingsByRisk.sorted(by: { $0.value > $1.value }), id: \.key) { risk, n in
                            AutonomosChrome.tag("\(risk): \(n)")
                        }
                    }
                    .accessibilityHidden(true)
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .stroke(incidentPresent ? AtlasTheme.domOperacional.opacity(0.4) : AtlasTheme.goldBorder, lineWidth: 1))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AutonomosOperationDigestA11y.spokenSection(
                deliveredTotal: deliveredTotal,
                pendingCount: pendingCount,
                inboxCount: inboxCount,
                incidentPresent: incidentPresent,
                oldestBacklogCreatedAt: oldestBacklogCreatedAt,
                findingsByRisk: findingsByRisk
            ))
            .accessibilityIdentifier(A11yID.autonomosOperationDigest)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                AutonomosChrome.sectionCaption("operação", role: .header)
                Text("Quieta nesta janela — nenhuma entrega, pendência nem incidente publicado.")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(AutonomosOperationDigestA11y.spokenQuiet())
            .accessibilityIdentifier(A11yID.autonomosOperationQuiet)
        }
    }
}
