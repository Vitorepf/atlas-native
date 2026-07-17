import Foundation
import AtlasCore

// Banner de reconexão — helpers no bubble (transporte + ledger). Peel CICLO B.
// Spoken/icon → ConversationCockpit+Reconnect+BubbleSpoken.swift
// Lines/timer → ConversationCockpit+Reconnect+BubbleLines.swift
// PrimaryLine → ConversationCockpit+Reconnect+Bubble+PrimaryLine.swift

extension ChatBubble {
    var showsReconnectSurface: Bool {
        reconnectNotice != nil
            || (streaming && executionPresentationState?.kind == .recovering)
    }
}
