import SwiftUI
import AtlasCore

struct AutonomosFleetHistorySection: View {
    let history: AtlasAutonomosFleetHistoryResponse

    private var visibleEvents: [AtlasAutonomosFleetHistoryEvent] {
        Array(history.events.prefix(AutonomosFleetHistoryA11y.visibleCap))
    }

    var body: some View {
        if history.events.isEmpty {
            AutonomosFleetEmptyState(kind: .noHistory)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                // A legenda conta o total: mostrar 6 de N sem dizer N faz o operador
                // ler "6" como "tudo". Nada cortado em silêncio.
                AutonomosChrome.sectionCaption(history.events.count > AutonomosFleetHistoryA11y.visibleCap
                               ? "HISTÓRICO DA FROTA · 6 DE \(history.events.count)"
                               : "HISTÓRICO DA FROTA")
                ForEach(Array(visibleEvents.enumerated()), id: \.element.id) { index, event in
                    HStack(alignment: .top, spacing: 10) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(index == 0 ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.35))
                                .frame(width: 7, height: 7)
                                .padding(.top, 5)
                            if index < visibleEvents.count - 1 {
                                Rectangle()
                                    .fill(AtlasTheme.accent.opacity(0.18))
                                    .frame(width: 1.5, height: 34)
                            }
                        }
                        .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(event.event)
                                .font(.system(.caption, weight: .semibold))
                                .foregroundStyle(AtlasTheme.textPrimary)
                            HStack(spacing: 6) {
                                AutonomosChrome.tag(event.agentKey)
                                if let by = event.by?.nonEmpty { AutonomosChrome.tag(by) }
                                if let account = event.account?.nonEmpty { AutonomosChrome.tag(account) }
                                if let pid = event.pid { AutonomosChrome.tag("pid \(pid)") }
                                if let duration = event.durationSeconds { AutonomosChrome.tag(AutonomosChrome.uptime(duration)) }
                            }
                            .accessibilityHidden(true)
                            if let reason = event.reason?.nonEmpty {
                                Text(reason)
                                    .font(.caption2)
                                    .foregroundStyle(AtlasTheme.textSecondary)
                                    .lineLimit(2)
                            }
                            Text(event.at)
                                .font(AtlasFont.mono(9))
                                .foregroundStyle(AtlasTheme.textTertiary)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(
                        AutonomosFleetHistoryA11y.spokenEvent(event, index: index, visible: visibleEvents.count)
                    )
                    .accessibilityIdentifier(A11yID.autonomosFleetHistoryRow(index))
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(AutonomosFleetHistoryA11y.spokenSection(total: history.events.count))
            .accessibilityIdentifier(A11yID.autonomosFleetHistorySection)
        }
    }
}
