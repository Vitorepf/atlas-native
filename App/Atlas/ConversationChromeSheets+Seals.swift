import SwiftUI
import AtlasCore

/// Selos de leitura — peel de ConversationChromeSheets+Receipt.
/// New marker → ConversationChromeSheets+NewMarker.swift · Body → +SealBody.swift

struct StaleReadSeal: View {
    let capturedAt: Date
    let confirming: Bool
    let reduceMotion: Bool

    var body: some View {
        Group {
            if reduceMotion || confirming {
                sealBody(now: Date())
            } else {
                TimelineView(.periodic(from: Date(), by: 60)) { context in
                    sealBody(now: context.date)
                }
            }
        }
        .accessibilityIdentifier(A11yID.conversationStaleReadSeal)
        .accessibilityAddTraits(confirming || reduceMotion ? .isStaticText : .updatesFrequently)
    }
}
