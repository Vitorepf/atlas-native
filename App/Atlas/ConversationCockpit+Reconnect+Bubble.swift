import Foundation
import AtlasCore

// Banner de reconexão — helpers no bubble (transporte + ledger). Peel CICLO B.
// Spoken/icon → ConversationCockpit+Reconnect+BubbleSpoken.swift
// Lines/timer → ConversationCockpit+Reconnect+BubbleLines.swift

extension ChatBubble {
    var showsReconnectSurface: Bool {
        reconnectNotice != nil
            || (streaming && executionPresentationState?.kind == .recovering)
    }

    /// Linha principal: aviso do stream quando existe; senão título público do ledger.
    var reconnectPrimaryLine: String? {
        if let notice = reconnectNotice { return notice }
        guard streaming, executionPresentationState?.kind == .recovering else { return nil }
        return executionPresentationState?.title
    }
}
