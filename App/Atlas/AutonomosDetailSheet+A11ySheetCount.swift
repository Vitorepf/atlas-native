import Foundation
import AtlasCore

// Sheet label counts — peel de AutonomosDetailSheet+A11y.

extension AutonomosPublicDetailSheet {
    func spokenSheetCountLabel(name: String, count: Int) -> String {
        if count == 0 {
            return "\(name), nenhum item público neste recorte"
        }
        if count == 1 {
            return "\(name), 1 item público"
        }
        return "\(name), \(count) itens públicos"
    }
}
