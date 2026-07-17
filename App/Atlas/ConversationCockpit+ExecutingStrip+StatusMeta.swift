import SwiftUI
import AtlasCore

// Timer + diff meta do strip — peel de ExecutingStrip+Status.
// EventTimer → ConversationCockpit+ExecutingStrip+StatusMeta+EventTimer.swift
// DiffStats → ConversationCockpit+ExecutingStrip+StatusMeta+DiffStats.swift

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusMeta: some View {
        stripStatusEventTimer
        stripStatusDiffStats
    }
}
