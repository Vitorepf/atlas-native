import SwiftUI
import UIKit

// Notification haptics — peel de AtlasMotion+Haptics.

extension AtlasMotion {
    static func successNotification(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
