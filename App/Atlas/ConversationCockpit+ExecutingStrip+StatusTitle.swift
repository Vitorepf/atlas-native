import SwiftUI
import AtlasCore

// Strip status title — peel de ConversationCockpit+ExecutingStrip+StatusLines.
// Activity → ConversationCockpit+ExecutingStrip+StatusActivity.swift
// Progress → ConversationCockpit+ExecutingStrip+StatusProgress.swift

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusTitle: some View {
        if bubble.showsReconnectSurface || bubble.executionProgress != nil {
            stripStatusReconnectOrProgress
        } else {
            stripStatusActivityOrIdle
        }
    }
}
