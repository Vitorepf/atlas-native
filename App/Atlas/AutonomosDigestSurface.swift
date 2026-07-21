import SwiftUI
import AtlasCore

// MARK: - Digest / moment surface (WAVE-038)

/// One domain: scheduled digest window → delivered · risks · pending.
struct AutonomosDigestSurface: View {
    let digest: AtlasAutonomosDigestResponse?

    private var face: AutonomosDigestFace {
        AutonomosDigestJudgment.face(from: digest)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AutonomosMapChrome.kicker(
                    face.productWord,
                    live: face.productWord == "attention"
                )
                .padding(.bottom, 14)
                AutonomosMapChrome.heroTitle(face.heroTitle, size: 28)
                    .padding(.bottom, 8)

                if let digest {
                    digestBody(digest)
                } else {
                    Text("Digest não publicado neste recorte. Nada inventado.")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .padding(.bottom, 140)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel(face.spokenFace)
    }

    @ViewBuilder
    private func digestBody(_ digest: AtlasAutonomosDigestResponse) -> some View {
        Text(AutonomosDigestJudgment.windowLine(digest))
            .font(AtlasFont.mono(12))
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.bottom, 6)
        Text(AutonomosDigestJudgment.countsLine(digest))
            .font(AtlasFont.serif(16, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.bottom, 8)
        if let schedule = AutonomosDigestJudgment.scheduleLine(digest) {
            Text(schedule)
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textSecondary)
                .padding(.bottom, 18)
        }

        let pending = AutonomosDigestJudgment.rankPending(digest.last.pendingDecisions)
        if !pending.isEmpty {
            sectionHeader("Decisões na janela")
            ForEach(pending) { item in
                row(
                    title: item.title,
                    meta: "\(item.severity) · prio \(item.priorityScore) · \(item.route)",
                    accent: true
                )
            }
        }

        let risks = AutonomosDigestJudgment.rankRisks(digest.last.risks)
        if !risks.isEmpty {
            sectionHeader("Riscos")
            ForEach(risks) { risk in
                row(
                    title: risk.title ?? risk.reason ?? "Risco \(risk.severity)",
                    meta: "\(risk.severity)\(risk.route.map { " · \($0)" } ?? "")",
                    accent: risk.severity.lowercased().contains("high")
                        || risk.severity.lowercased().contains("crit")
                )
            }
        }

        let delivered = AutonomosDigestJudgment.rankDelivered(digest.last.delivered)
        if !delivered.isEmpty {
            sectionHeader("Entregas")
            ForEach(delivered) { d in
                row(
                    title: "Ciclo \(d.cycleIndex) · \(d.outcome)",
                    meta: "\(d.cycleFinalStatus)\(d.mergePerformed ? " · merge" : "") · \(d.recordedAt)",
                    accent: d.mergePerformed
                )
            }
        }

        if pending.isEmpty && risks.isEmpty && delivered.isEmpty {
            Text("Janela sem itens publicados. Silêncio honesto.")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.top, 8)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        AutonomosMapChrome.section(title)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }

    private func row(title: String, meta: String, accent: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AtlasFont.serif(16, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(meta)
                .font(AtlasFont.mono(11))
                .foregroundStyle(accent ? AtlasTheme.accent : AtlasTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) { AutonomosMapChrome.hairline }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(meta)")
    }
}
