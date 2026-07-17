import Foundation
import AtlasCore

// Spoken helpers — peel de AtlasCodeWhySheet+A11y.

extension AtlasCodeWhySheet {
    func spokenLoading() -> String { "lendo a história do arquivo" }

    func spokenFailed() -> String {
        if let message = model.message, !message.isEmpty {
            return "biografia indisponível, \(message)"
        }
        return "biografia indisponível"
    }

    func spokenEmptyHistory() -> String { "este arquivo não tem história neste recorte" }
}
