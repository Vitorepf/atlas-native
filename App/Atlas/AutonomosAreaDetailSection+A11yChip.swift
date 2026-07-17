import Foundation
import AtlasCore

// Chip spoken — peel de AutonomosAreaDetailA11y.

extension AutonomosAreaDetailA11y {
    static func spokenChip(kind: AutonomosDetailSheet, count: Int?) -> String {
        let name = kind.title.lowercased()
        if kind == .budgets {
            return count != nil ? "abrir orçamentos públicos" : "abrir orçamentos, dados não publicados"
        }
        guard let count else { return "abrir \(name), contagens não publicadas" }
        if count == 0 { return "abrir \(name), nenhum item público neste recorte" }
        if count == 1 { return "abrir \(name), 1 item público" }
        return "abrir \(name), \(count) itens públicos"
    }
}
