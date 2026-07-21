import SwiftUI
import AtlasCore

// Copy mentions leave predicate — peel de ExecutionStateCard+AwaitingFailed+Retry.

extension ExecutionStateCard {
    static func copyMentionsCanLeave(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        return text.contains("pode sair")
    }
}
