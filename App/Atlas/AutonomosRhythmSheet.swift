import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: AutonomosRhythm sheet+judgment fused

// MARK: - Judgment

// MARK: - Types

/// Exclusive Autônomos day-rhythm face (WAVE-077).
enum AutonomosRhythmFace: Equatable {
    case learning(day: Int)
    case learned
    case paused

    var productWord: String {
        switch self {
        case .learning: return "learning"
        case .learned: return "learned"
        case .paused: return "paused"
        }
    }

    var spokenFace: String {
        switch self {
        case .learning(let day):
            return "aprendendo seu ritmo, dia \(day) de 4"
        case .learned:
            return "ritmo aprendido"
        case .paused:
            return "propostas noturnas em pausa"
        }
    }
}

// MARK: - Judgment

/// Pure day-rhythm grammar — face · line · spoken · paragraphs · pack.
enum AutonomosRhythmJudgment {

    static let learningThresholdDays = 4

    static func face(
        sampleDays: Int,
        paused: Bool
    ) -> AutonomosRhythmFace {
        if paused { return .paused }
        if sampleDays < learningThresholdDays {
            return .learning(day: max(1, sampleDays))
        }
        return .learned
    }

    static func face(
        windows: AtlasDayRhythm.Windows,
        paused: Bool
    ) -> AutonomosRhythmFace {
        face(sampleDays: windows.sampleDays, paused: paused)
    }

    static func hour(_ components: DateComponents?) -> String? {
        guard let hour = components?.hour else { return nil }
        return String(format: "%02d:%02d", hour, components?.minute ?? 0)
    }

    static func line(
        windows: AtlasDayRhythm.Windows,
        paused: Bool = false
    ) -> String {
        let base: String
        if windows.sampleDays < learningThresholdDays {
            base = "aprendendo seu ritmo · dia \(max(1, windows.sampleDays)) de \(learningThresholdDays)"
        } else if let dayEnd = hour(windows.dayEnd) {
            base = "ritmo aprendido · seu dia termina ~\(dayEnd)"
        } else {
            base = "ritmo aprendido · \(windows.sampleDays) dias de uso"
        }
        return paused ? "\(base) · propostas em pausa" : base
    }

    static func spokenLine(
        windows: AtlasDayRhythm.Windows,
        paused: Bool = false
    ) -> String {
        let base: String
        if windows.sampleDays < learningThresholdDays {
            base = "aprendendo seu ritmo, dia \(max(1, windows.sampleDays)) de \(learningThresholdDays)"
        } else if let dayEnd = hour(windows.dayEnd) {
            base = "ritmo aprendido: seu dia costuma terminar perto das \(dayEnd)"
        } else {
            base = "ritmo aprendido em \(windows.sampleDays) dias de uso"
        }
        return paused ? "\(base). Propostas noturnas em pausa" : base
    }

    static func learnedParagraph(_ windows: AtlasDayRhythm.Windows) -> String {
        if windows.sampleDays < learningThresholdDays {
            let left = learningThresholdDays - windows.sampleDays
            return "O Atlas observa quando seu dia de trabalho começa e termina. Faltam \(left) \(left == 1 ? "dia" : "dias") para ele conhecer seu ritmo."
        }
        return "O Atlas aprendeu seu ritmo observando o uso real — a mediana dos seus últimos dias de trabalho."
    }

    static func whatHappensParagraph(_ windows: AtlasDayRhythm.Windows) -> String {
        if windows.sampleDays < learningThresholdDays {
            return "Quando o ritmo estiver aprendido, no fim do seu dia o Atlas vai propor uma missão noturna — a frota continua enquanto você descansa."
        }
        return "No fim do seu dia, se houve trabalho, o Atlas propõe uma missão noturna — a frota continua enquanto você descansa, e de manhã o resultado espera por você."
    }

    static func packFacts(
        windows: AtlasDayRhythm.Windows,
        paused: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(windows: windows, paused: paused)
        facts.append("rhythm_face: \(face.productWord)")
        facts.append("rhythm_sample_days: \(windows.sampleDays)")
        if let dayEnd = hour(windows.dayEnd) {
            facts.append("rhythm_day_end: \(dayEnd)")
        } else {
            absences.append("hora de fim do dia ainda não aprendida")
        }
        if let dayStart = hour(windows.dayStart) {
            facts.append("rhythm_day_start: \(dayStart)")
        }
        switch face {
        case .learning:
            absences.append("ritmo ainda em amostragem (< \(learningThresholdDays) dias)")
        case .learned:
            break
        case .paused:
            absences.append("propostas noturnas em pausa sobre o ritmo")
        }
        return (facts, absences)
    }
}

// MARK: - Sheet

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
