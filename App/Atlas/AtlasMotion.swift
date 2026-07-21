import SwiftUI
import UIKit

// IDLE-COMPRESS fused

// --- AtlasMotion+Haptics+Impact.swift ---
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

// --- AtlasMotion+Haptics+Notification.swift ---
extension AtlasMotion {
    static func successNotification(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// --- AtlasMotion+Presentation.swift ---
struct NumericTextTransition: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.contentTransition(.numericText())
        } else {
            content
        }
    }
}

// --- AtlasMotion+PresentationHelpers.swift ---
@MainActor
enum AtlasMotionPresentation {
    static func editorial(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : AtlasMotion.editorial
    }

    static func rowTransition(reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .identity : .opacity.combined(with: .move(edge: .top))
    }
}

extension View {
    func atlasNumericTransition(reduceMotion: Bool) -> some View {
        modifier(NumericTextTransition(enabled: !reduceMotion))
    }
}

// --- AtlasMotion.swift ---
enum AtlasMotion {
    static let instinct: Double = 0.18
    static let considered: Double = 0.32
    static let ceremonial: Double = 0.48
    static let sacred: Double = 0.62

    static let editorial = Animation.timingCurve(0.22, 1, 0.36, 1, duration: considered)
    static let arrival = Animation.spring(response: 0.42, dampingFraction: 0.82)
    static func breath(_ duration: Double = 0.9) -> Animation {
        .easeInOut(duration: duration).repeatForever(autoreverses: true)
    }
}
