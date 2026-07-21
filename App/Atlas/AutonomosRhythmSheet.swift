import AtlasCore
import Foundation
import SwiftUI

// IDLE-COMPRESS fused

struct AutonomosRhythmSheet: View {
    let windows: AtlasDayRhythm.Windows
    @State private var today: AtlasDayRhythm.DaySummary?
    @State private var nightly = NightlyProposalController.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("APRENDER COM O USO")
                .font(AtlasFont.mono(10, .semibold))
                .foregroundStyle(AtlasTheme.accent)
                .kerning(1.2)
            Text("O ritmo do seu dia")
                .font(AtlasFont.serif(22, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)

            Text(AutonomosRhythmCopy.learnedParagraph(windows))
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                if let dayStart = AutonomosRhythmCopy.hour(windows.dayStart) {
                    rhythmRow("dia começa", "~\(dayStart)")
                }
                if let dayEnd = AutonomosRhythmCopy.hour(windows.dayEnd) {
                    rhythmRow("dia termina", "~\(dayEnd)")
                }
                rhythmRow("amostra", "\(windows.sampleDays) \(windows.sampleDays == 1 ? "dia" : "dias") de uso")
                rhythmRow("hoje", AutonomosRhythmCopy.todayLine(today))
                if let score = AutonomosRhythmCopy.scoreLine(AtlasSession.nightlyProposalScore()) {
                    rhythmRow("propostas", score)
                }
                if let adjustment = AutonomosRhythmCopy.adjustmentLine(AtlasSession.nightlyProposalAdjustmentMinutes()) {
                    rhythmRow("ajuste", adjustment)
                }
            }

            Text(AutonomosRhythmCopy.whatHappensParagraph(windows))
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if let muted = nightly.spokenMuteStatus() {
                VStack(alignment: .leading, spacing: 8) {
                    Text(muted)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                    Button("Reativar propostas noturnas") {
                        nightly.unmuteProposal()
                    }
                    .font(AtlasFont.mono(11, .semibold))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityIdentifier(A11yID.autonomosRhythmUnmute)
                }
            }

            Spacer(minLength: 0)

            Text("aprendido e guardado só neste iPhone — nada sai do aparelho")
                .font(AtlasFont.mono(9.5))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(AtlasTheme.bg)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.autonomosRhythmSheet)
        .accessibilityValue(
            AutonomosRhythmJudgment.face(
                windows: windows,
                paused: nightly.isProposalMuted
            ).productWord
        )
        .task { today = await AtlasSession.rhythm.todaySummary() }
    }

    private func rhythmRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(width: 84, alignment: .leading)
            Text(value)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textPrimary)
        }
        .accessibilityElement(children: .combine)
    }
}

/// WAVE-077: presentation peels → AutonomosRhythmJudgment for face grammar.
enum AutonomosRhythmCopy {
    static func line(_ windows: AtlasDayRhythm.Windows, paused: Bool = false) -> String {
        AutonomosRhythmJudgment.line(windows: windows, paused: paused)
    }

    static func spokenLine(_ windows: AtlasDayRhythm.Windows, paused: Bool = false) -> String {
        AutonomosRhythmJudgment.spokenLine(windows: windows, paused: paused)
    }

    static func learnedParagraph(_ windows: AtlasDayRhythm.Windows) -> String {
        AutonomosRhythmJudgment.learnedParagraph(windows)
    }

    static func whatHappensParagraph(_ windows: AtlasDayRhythm.Windows) -> String {
        AutonomosRhythmJudgment.whatHappensParagraph(windows)
    }

    static func todayLine(_ today: AtlasDayRhythm.DaySummary?) -> String {
        guard let today, !today.workspaces.isEmpty else {
            return "nenhum trabalho registrado ainda"
        }
        return today.workspaces.joined(separator: " · ")
    }

    static func scoreLine(_ score: (accepted: Int, dismissed: Int)) -> String? {
        guard score.accepted + score.dismissed > 0 else { return nil }
        let aceitas = "\(score.accepted) \(score.accepted == 1 ? "aceita" : "aceitas")"
        let recusadas = "\(score.dismissed) \(score.dismissed == 1 ? "recusada" : "recusadas")"
        return "\(aceitas) · \(recusadas)"
    }

    static func adjustmentLine(_ minutes: Int) -> String? {
        guard minutes > 0 else { return nil }
        return "+\(minutes) min — seu horário real de resposta"
    }

    static func hour(_ components: DateComponents?) -> String? {
        AutonomosRhythmJudgment.hour(components)
    }
}
