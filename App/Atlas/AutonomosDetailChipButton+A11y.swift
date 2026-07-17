import Foundation
import AtlasCore

/// Spoken labels dos chips de detalhe público — peel de AutonomosDetailChipButton (CICLO C).

enum AutonomosDetailChipButtonA11y {
    static func spokenLabel(label: String, spoken: String?) -> String {
        spoken ?? "abrir detalhes de \(label)"
    }

    static func hint(kind: AutonomosDetailSheet) -> String {
        "abre a lista pública de \(kind.title.lowercased())"
    }
}
