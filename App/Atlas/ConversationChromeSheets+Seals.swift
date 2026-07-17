import SwiftUI
import AtlasCore

/// Selos de leitura — peel de ConversationChromeSheets+Receipt.
/// New marker → ConversationChromeSheets+NewMarker.swift · Body → +SealBody.swift
/// TimelineGate → ConversationChromeSheets+Seals+TimelineGate.swift

struct StaleReadSeal: View {
    let capturedAt: Date
    let confirming: Bool
    let reduceMotion: Bool

    var body: some View {
        sealTimelineGate(now: Date())
            .accessibilityIdentifier(A11yID.conversationStaleReadSeal)
            .accessibilityAddTraits(confirming || reduceMotion ? .isStaticText : .updatesFrequently)
    }
}
