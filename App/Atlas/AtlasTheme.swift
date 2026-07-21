import SwiftUI
import UIKit

// GOD-RESTRUCTURE: design system Theme+Motion+Glass fused

// MARK: - AtlasTheme

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

private struct AtlasCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let fillOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(AtlasTheme.surface.opacity(fillOpacity)))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(AtlasTheme.separator, lineWidth: 1))
    }
}

extension View {
    func atlasCard(cornerRadius: CGFloat = AtlasTheme.Radius.card, fillOpacity: Double = 1) -> some View {
        modifier(AtlasCardModifier(cornerRadius: cornerRadius, fillOpacity: fillOpacity))
    }
}

extension AtlasTheme {
    static let domOperacional = Color(hex: 0x9B7A3F) // bronze
    static let domAutonomos = Color(hex: 0x6FA06A)   // verde (moss clareado p/ dark)

    enum Space {
        static let screen: CGFloat = 20
        static let row: CGFloat = 13
    }
}

extension AtlasTheme {
    static let textPrimary = Color(hex: 0xD6DDE2)
    static let textSecondary = Color(hex: 0x95A3AC)
    static let textTertiary = Color(hex: 0x677482)
    static let accent = Color(hex: 0xD4A85A)
    static let goldVeil = Color(hex: 0xD4A85A, alpha: 0.10)
    static let goldBorder = Color(hex: 0xD4A85A, alpha: 0.34)
    static let prussian = Color(hex: 0x7FA7C4)
    static let alert = Color(hex: 0xE08C8C)
}

extension AtlasTheme {
    enum Radius {
        static let card: CGFloat = 14
        static let control: CGFloat = 12
        static let soft: CGFloat = 10
    }
}

extension AtlasTheme {
    static let bg = Color(hex: 0x1D2B34)
    static let bgRecessed = Color(hex: 0x15212A)
    static let surface = Color(hex: 0x243743)
    static let surfaceHi = Color(hex: 0x2D4351)
    static let separator = Color(hex: 0x313F47)
    static let separatorSoft = Color(hex: 0x27353E)
}

enum AtlasTheme {}
// MARK: - AtlasMotion

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
// MARK: - AtlasGlassCircle

struct AtlasGlassCircle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: Circle())
        } else {
            content.background(Circle().fill(AtlasTheme.surface))
        }
    }
}

struct AtlasGlassCapsule: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: Capsule())
        } else {
            // Fallback pré-26: recessed quieto (mockup home), não surface chapado.
            content.background(
                Capsule().fill(AtlasTheme.bgRecessed.opacity(0.82))
                    .overlay(Capsule().stroke(AtlasTheme.separator.opacity(0.9), lineWidth: 1)))
        }
    }
}

/// Chrome único da pílula agêntica = craft Home (lei pétrea pílula §2).
/// Vidro + fio de ouro artesanal. Só o convite muda por superfície.
struct AtlasAgenticPillChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            // Hit-test friendly fill sob glass no iOS 26 (identifier não some).
            .background { Capsule().fill(AtlasTheme.bgRecessed.opacity(0.01)) }
            .atlasGlassCapsule()
            .overlay(
                Capsule()
                    .strokeBorder(Self.goldFilament, lineWidth: 0.75)
            )
    }

    /// Fio de ouro da home — não goldBorder chapado, não shadow solto.
    static var goldFilament: LinearGradient {
        LinearGradient(
            colors: [
                AtlasTheme.accent.opacity(0.22),
                AtlasTheme.accent.opacity(0.04),
                AtlasTheme.accent.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func atlasGlassCircle() -> some View { modifier(AtlasGlassCircle()) }
    /// Mesma lei para pílulas/cápsulas de chrome (composer da home, new pill).
    func atlasGlassCapsule() -> some View { modifier(AtlasGlassCapsule()) }
    /// Chrome canônico da pílula: glass + fio de ouro Home. Use em toda superfície.
    func atlasAgenticPillChrome() -> some View { modifier(AtlasAgenticPillChrome()) }
}
