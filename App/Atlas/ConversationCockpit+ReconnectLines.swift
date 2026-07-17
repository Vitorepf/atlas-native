import SwiftUI
import AtlasCore

// Secondary lines + timer — peel de ReconnectBanner.
// Loop → ConversationCockpit+ReconnectLines+SecondaryLoop.swift
// Timer → ConversationCockpit+ReconnectLines+ActiveTimer.swift

extension ReconnectBanner {
    @ViewBuilder
    var secondaryLines: some View {
        reconnectSecondaryLoop
        reconnectActiveTimerLine
    }
}
