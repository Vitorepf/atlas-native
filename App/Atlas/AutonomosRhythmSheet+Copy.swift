import Foundation
import AtlasCore

/// Copy do ritmo — a linha, as falas e os parágrafos da folha. Toda afirmação
/// vem das janelas reais; aprendizado incompleto é dito como incompleto.
enum AutonomosRhythmCopy {
    static func line(_ windows: AtlasDayRhythm.Windows) -> String {
        if windows.sampleDays < 4 {
            return "aprendendo seu ritmo · dia \(max(1, windows.sampleDays)) de 4"
        }
        if let dayEnd = hour(windows.dayEnd) {
            return "ritmo aprendido · seu dia termina ~\(dayEnd)"
        }
        return "ritmo aprendido · \(windows.sampleDays) dias de uso"
    }

    static func spokenLine(_ windows: AtlasDayRhythm.Windows) -> String {
        if windows.sampleDays < 4 {
            return "aprendendo seu ritmo, dia \(max(1, windows.sampleDays)) de 4"
        }
        if let dayEnd = hour(windows.dayEnd) {
            return "ritmo aprendido: seu dia costuma terminar perto das \(dayEnd)"
        }
        return "ritmo aprendido em \(windows.sampleDays) dias de uso"
    }

    static func learnedParagraph(_ windows: AtlasDayRhythm.Windows) -> String {
        if windows.sampleDays < 4 {
            return "O Atlas observa quando seu dia de trabalho começa e termina. Faltam \(4 - windows.sampleDays) \(4 - windows.sampleDays == 1 ? "dia" : "dias") para ele conhecer seu ritmo."
        }
        return "O Atlas aprendeu seu ritmo observando o uso real — a mediana dos seus últimos dias de trabalho."
    }

    static func whatHappensParagraph(_ windows: AtlasDayRhythm.Windows) -> String {
        if windows.sampleDays < 4 {
            return "Quando o ritmo estiver aprendido, no fim do seu dia o Atlas vai propor uma missão noturna — a frota continua enquanto você descansa."
        }
        return "No fim do seu dia, se houve trabalho, o Atlas propõe uma missão noturna — a frota continua enquanto você descansa, e de manhã o resultado espera por você."
    }

    static func todayLine(_ today: AtlasDayRhythm.DaySummary?) -> String {
        guard let today, !today.workspaces.isEmpty else {
            return "nenhum trabalho registrado ainda"
        }
        return today.workspaces.joined(separator: " · ")
    }

    /// Placar só existe depois da primeira resposta — zero histórico, zero linha.
    static func scoreLine(_ score: (accepted: Int, dismissed: Int)) -> String? {
        guard score.accepted + score.dismissed > 0 else { return nil }
        let aceitas = "\(score.accepted) \(score.accepted == 1 ? "aceita" : "aceitas")"
        let recusadas = "\(score.dismissed) \(score.dismissed == 1 ? "recusada" : "recusadas")"
        return "\(aceitas) · \(recusadas)"
    }

    static func hour(_ components: DateComponents?) -> String? {
        guard let hour = components?.hour else { return nil }
        return String(format: "%02d:%02d", hour, components?.minute ?? 0)
    }
}
