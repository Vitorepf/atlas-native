import Foundation

/// Seal display caption — peel de ConversationChromeSheets+Seals+A11y.

extension StaleReadSealA11y {
    static func displayCaption(
        capturedAt: Date,
        now: Date,
        confirming: Bool,
        reduceMotion: Bool
    ) -> String {
        if confirming {
            return reduceMotion ? "leitura atualizada" : "leitura sincronizada"
        }
        return "visto há \(atlasRelativeAgePT(since: capturedAt, now: now))"
    }
}
