import SwiftUI
import UIKit
import AtlasCore

// Handoff receipt surface — peel de ConversationViewChrome+Toast.

extension ConversationView {
    @ViewBuilder var handoffReceipt: some View {
        if let handoff = model.latestSurfaceHandoff {
            ConversationHandoffReceipt(handoff: handoff)
        }
    }
}
