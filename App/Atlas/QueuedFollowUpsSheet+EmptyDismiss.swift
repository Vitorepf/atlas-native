import SwiftUI

// Empty queue dismiss — peel de QueuedFollowUpsSheet.

extension QueuedFollowUpsSheet {
    var emptyQueueDismiss: some View {
        Color.clear.onAppear { dismiss() }
    }
}
