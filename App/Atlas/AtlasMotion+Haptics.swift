import SwiftUI
import UIKit

// Cycle 041 fuse → AtlasMotion+Haptics.swift

extension AtlasMotion {
    static func softImpact(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func mediumImpact(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func lightImpact(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

extension AtlasMotion {
    static func successNotification(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
