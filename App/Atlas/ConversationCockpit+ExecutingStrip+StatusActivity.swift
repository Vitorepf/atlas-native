import SwiftUI
import AtlasCore

// Strip status title activity branch — peel de StatusTitle.
// Row → ConversationCockpit+ExecutingStrip+StatusActivityRow.swift

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusActivityOrIdle: some View {
        if let act = bubble.currentActivity {
            stripStatusActivityRow(act)
        } else {
            stripStatusIdleLine
        }
    }
}
