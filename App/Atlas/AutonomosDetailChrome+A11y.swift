import Foundation

/// Spoken helpers do chrome de detalhe Autônomos — peel de AutonomosDetailChrome (CICLO C).
/// Valor vazio = «não publicado»; nunca inventa placeholder falado.

enum AutonomosDetailChromeA11y {
    static func spokenField(label: String, value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "\(label), não publicado"
        }
        return "\(label), \(trimmed)"
    }

    static func spokenCard(_ title: String) -> String {
        "detalhe \(title)"
    }
}
