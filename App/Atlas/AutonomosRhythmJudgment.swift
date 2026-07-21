import Foundation
import AtlasCore

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
