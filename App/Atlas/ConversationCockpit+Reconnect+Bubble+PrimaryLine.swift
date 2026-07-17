import Foundation
import AtlasCore

// Linha principal — peel de ConversationCockpit+Reconnect+Bubble.

extension ChatBubble {
    /// Linha principal: aviso do stream quando existe; senão título público do ledger.
    var reconnectPrimaryLine: String? {
        if let notice = reconnectNotice { return notice }
        guard streaming, executionPresentationState?.kind == .recovering else { return nil }
        return executionPresentationState?.title
    }
}
