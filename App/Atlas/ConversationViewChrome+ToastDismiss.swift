import SwiftUI
import UIKit
import AtlasCore

// Toast auto-dismiss — peel de ConversationViewChrome+Toast.

extension ConversationView {
    func dismissToastAfterDelay() async {
        try? await Task.sleep(nanoseconds: 1_400_000_000)
        clearToast()
    }
}
