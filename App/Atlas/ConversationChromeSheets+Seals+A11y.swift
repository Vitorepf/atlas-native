import Foundation

/// Spoken labels dos selos de leitura — peel de ConversationChromeSheets+Seals (CICLO C).
/// Caption → ConversationChromeSheets+Seals+A11yCaption.swift

enum StaleReadSealA11y {
    static func spokenLabel(
        capturedAt: Date,
        now: Date,
        confirming: Bool,
        reduceMotion: Bool
    ) -> String {
        if confirming {
            return reduceMotion
                ? "histórico salvo atualizado"
                : "histórico salvo atualizado após sincronizar"
        }
        return "histórico salvo visto há \(atlasRelativeAgePT(since: capturedAt, now: now))"
    }
}
