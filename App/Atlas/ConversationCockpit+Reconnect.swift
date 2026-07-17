import SwiftUI
import AtlasCore

// Banner de reconexão — só `reconnectNotice` (transporte) e
// `executionPresentationState` `.recovering` (ledger). Helpers → +Bubble.
// Lines → ConversationCockpit+ReconnectLines.swift
// Body → ConversationCockpit+ReconnectBody.swift

struct ReconnectBanner: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    var body: some View {
        if bubble.showsReconnectSurface, let primary = bubble.reconnectPrimaryLine {
            reconnectBannerBody(primary: primary)
        }
    }
}
