import SwiftUI
import AtlasCore

// Strip reconnect/progress titles — peel de StatusTitle.
// Reconnect → ConversationCockpit+ExecutingStrip+StatusProgress+ReconnectLine.swift
// Progress → ConversationCockpit+ExecutingStrip+StatusProgress+ProgressLine.swift

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusReconnectOrProgress: some View {
        if bubble.showsReconnectSurface, bubble.reconnectPrimaryLine != nil {
            stripStatusReconnectLine
        } else if bubble.executionProgress != nil {
            stripStatusProgressLine
        }
    }
}
