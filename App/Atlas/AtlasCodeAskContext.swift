import Foundation
import AtlasCore

/// Pack de ocasião do Grafo/Código — presentation-only.
/// Pílula e emptyPrompt falam o **mesmo** convite; facts vêm de `AtlasCodeAskModel`.
enum AtlasCodeAskContext {
    static let invite = "pergunte sobre este repositório"

    /// Sugestões canônicas Core (H6) — só o que o Atlas sabe responder.
    static var emptySuggestions: [String] { AtlasCodeAskSuggestions.all }

    /// Empty prompt da conversa: âncora de swipe se houver, senão convite do grafo.
    static func emptyPrompt(focusLegend: String?) -> String {
        if let focusLegend, !focusLegend.isEmpty {
            return "sobre \(focusLegend) — o que você quer saber?"
        }
        return invite
    }
}
