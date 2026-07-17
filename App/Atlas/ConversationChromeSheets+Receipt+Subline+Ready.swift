import SwiftUI
import AtlasCore

// Ready subline — peel de ConversationChromeSheets+Receipt+Subline.

extension ConversationHandoffReceipt {
    func readySubline(route: String, thread: String, age: String?) -> String {
        var parts = ["\(route)", "mesma thread \(thread)", "sem prompt duplicado"]
        if let age { parts.append("há \(age)") }
        return parts.joined(separator: " · ")
    }
}
