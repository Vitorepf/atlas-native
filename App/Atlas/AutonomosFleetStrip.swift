import SwiftUI
import AtlasCore

// MARK: - Thin fleet strip on Autônomos catalog (WAVE-037)

/// One domain: published global fleet snapshot — not a monólito map.
struct AutonomosFleetStrip: View {
    let fleet: AtlasAutonomosFleetResponse
    var history: AtlasAutonomosFleetHistoryResponse? = nil

    private var face: AutonomosFleetFace {
        AutonomosFleetJudgment.face(from: fleet)
    }

    private var agents: [AtlasAutonomosFleetAgent] {
        AutonomosFleetJudgment.rank(fleet.agents)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                AutonomosMapChrome.kicker(
                    face.kicker,
                    live: face.productWord == "live" || face.productWord == "attention"
                )
                Spacer(minLength: 0)
                Text(AutonomosFleetJudgment.summaryLine(fleet))
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
            }

            if agents.isEmpty {
                Text("Snapshot publicado sem agentes neste recorte.")
                    .font(AtlasFont.serifItalic(13))
                    .foregroundStyle(AtlasTheme.textTertiary)
            } else {
                ForEach(agents.prefix(6)) { agent in
                    agentRow(agent)
                }
                if agents.count > 6 {
                    Text("+\(agents.count - 6) agentes no snapshot")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
            }

            let events = AutonomosFleetJudgment.recentEvents(history, limit: 3)
            if !events.isEmpty {
                Text("Histórico")
                    .font(AtlasFont.mono(10))
                    .tracking(0.8)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.top, 4)
                ForEach(events) { event in
                    Text("\(event.event) · \(event.agentKey) · \(event.at)")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.vertical, 12)
        .background(AtlasTheme.surface.opacity(0.35))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(face.spokenFace)
        .accessibilityIdentifier(A11yID.autonomosFleetMap)
    }

    private func agentRow(_ agent: AtlasAutonomosFleetAgent) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Circle()
                .fill(agent.alive ? AtlasTheme.accent.opacity(0.9) : AtlasTheme.textTertiary.opacity(0.5))
                .frame(width: 6, height: 6)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 2) {
                Text(agent.label)
                    .font(AtlasFont.serif(15, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                Text(AutonomosFleetJudgment.agentMeta(agent))
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(
                        AutonomosFleetJudgment.needsAttention(agent)
                            ? AtlasTheme.domOperacional
                            : AtlasTheme.textTertiary
                    )
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AutonomosFleetJudgment.spokenAgent(agent))
    }
}
