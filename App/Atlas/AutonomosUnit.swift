import Foundation

/// Autônomo do operador (escopo fechado). Persistência Server = OBRA §5.
/// Em memória no AutonomosModel até existir create no Core (casca não faz storage).
struct AutonomosUnit: Identifiable, Equatable, Hashable {
    let id: String
    var name: String
    var charter: String
    var createdAt: Date
    var paused: Bool

    var ageLabel: String {
        let seconds = max(0, Int(Date().timeIntervalSince(createdAt)))
        if seconds < 60 { return "agora" }
        if seconds < 3600 { return "\(seconds / 60)m" }
        if seconds < 86_400 { return "\(seconds / 3600)h" }
        let days = seconds / 86_400
        return days == 1 ? "1 dia" : "\(days) dias"
    }
}
