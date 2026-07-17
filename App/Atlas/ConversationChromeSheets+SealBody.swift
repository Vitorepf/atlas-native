import SwiftUI
import AtlasCore

/// Corpo visual do selo stale — peel de ConversationChromeSheets+Seals.
/// Chrome → ConversationChromeSheets+SealChrome.swift

extension StaleReadSeal {
    @ViewBuilder
    func sealBody(now: Date) -> some View {
        sealChrome(now: now)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(StaleReadSealA11y.spokenLabel(
                capturedAt: capturedAt,
                now: now,
                confirming: confirming,
                reduceMotion: reduceMotion
            ))
    }
}
