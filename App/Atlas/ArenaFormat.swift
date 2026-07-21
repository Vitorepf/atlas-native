import Foundation
import AtlasCore

// Formatação de scores/deltas da Arena — peel de ArenaModel (régua ~120).

enum ArenaFormat {
    private static let scoreStyle = FloatingPointFormatStyle<Double>.number
        .locale(Locale(identifier: "pt_BR"))
        .grouping(.never)
        .precision(.fractionLength(0...1))

    private static let multiplierStyle = FloatingPointFormatStyle<Double>.number
        .locale(Locale(identifier: "pt_BR"))
        .grouping(.never)
        .precision(.fractionLength(2))

    static func score(_ value: Double?) -> String {
        guard let value = AtlasArenaPresentationScale.score(value) else {
            return "não medido"
        }
        return value.formatted(scoreStyle)
    }

    static func signed(_ value: Double?) -> String {
        guard let value = AtlasArenaPresentationScale.delta(value) else {
            return "—"
        }
        if abs(value) < 0.05 {
            return "0"
        }
        return "\(value > 0 ? "+" : "")\(value.formatted(scoreStyle))"
    }

    static func multiplier(_ value: Double?) -> String {
        guard let value else { return "—" }
        return "×\(value.formatted(multiplierStyle))"
    }
}
