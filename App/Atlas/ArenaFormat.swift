import Foundation

// Formatação de scores/deltas da Arena — peel de ArenaModel (régua ~120).

enum ArenaFormat {
    static func score(_ value: Double?) -> String {
        guard let value else { return "não medido" }
        return String(format: "%.2f", value)
    }

    static func signed(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%@%.2f", value >= 0 ? "+" : "", value)
    }

    static func multiplier(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "×%.2f", value)
    }
}
