import AtlasCore
import SwiftUI


/// Chrome tipográfico do mapa Autônomos v5 — sem cards, sem chips, sem ouro de chrome.
enum AutonomosMapChrome {
    static func kicker(_ text: String, live: Bool, alert: Bool = false) -> some View {
        HStack(spacing: 8) {
            if live || alert {
                Text(alert ? "※" : "✦")
                    .font(AtlasFont.serif(12))
                    .foregroundStyle(alert ? AtlasTheme.alert : AtlasTheme.accent)
                    .accessibilityHidden(true)
            }
            Text(text.uppercased())
                .font(AtlasFont.mono(10))
                .tracking(1.4)
                .foregroundStyle(alert ? AtlasTheme.alert : (live ? AtlasTheme.accent : AtlasTheme.textTertiary))
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    static func heroTitle(_ text: String, size: CGFloat = 30) -> some View {
        Text(text)
            .font(AtlasFont.serif(size, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }

    @MainActor
    static func heroSub(_ text: String) -> some View {
        Text(text)
            .atlasSans(14)
            .foregroundStyle(AtlasTheme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    static var hairline: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        AtlasTheme.separator.opacity(0.12),
                        AtlasTheme.separator.opacity(0.95),
                        AtlasTheme.separator.opacity(0.12)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .padding(.vertical, 4)
            .accessibilityHidden(true)
    }

    static func section(_ text: String) -> some View {
        Text(text.uppercased())
            .font(AtlasFont.mono(10))
            .tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityAddTraits(.isHeader)
    }

    enum CTAHaptic {
        case soft
        case medium
    }

    @MainActor
    static func primaryCTA(
        _ title: String,
        enabled: Bool = true,
        haptic: CTAHaptic = .soft,
        action: @escaping () -> Void
    ) -> some View {
        AutonomosMapPrimaryCTA(title: title, enabled: enabled, haptic: haptic, action: action)
    }

    @MainActor
    static func quietCTA(_ title: String, danger: Bool = false, action: @escaping () -> Void) -> some View {
        AutonomosMapQuietCTA(title: title, danger: danger, action: action)
    }
}

/// Primary map CTA — Environment Reduce Motion (not UIAccessibility global).
private struct AutonomosMapPrimaryCTA: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    var enabled: Bool = true
    var haptic: AutonomosMapChrome.CTAHaptic = .soft
    let action: () -> Void

    var body: some View {
        Button {
            if enabled {
                switch haptic {
                case .soft: AtlasMotion.softImpact(reduceMotion: reduceMotion)
                case .medium: AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                }
            }
            action()
        } label: {
            Text(title)
                .atlasSans(14, .medium)
                .foregroundStyle(AtlasTheme.textPrimary.opacity(enabled ? 1 : 0.35))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .background(AtlasTheme.textPrimary.opacity(enabled ? 0.055 : 0.03), in: Capsule())
                .overlay(Capsule().strokeBorder(Color.white.opacity(enabled ? 0.1 : 0.04), lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(enabled ? "confirma \(title.lowercased())" : "indisponível"))
        .accessibilityAddTraits(.isButton)
    }
}

private struct AutonomosMapQuietCTA: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    var danger: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            // Soft invitation; medium when danger (governed destructive quiet CTA).
            if danger {
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            } else {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
            }
            action()
        } label: {
            Text(title)
                .atlasSans(14)
                .foregroundStyle(danger ? AtlasTheme.alert : AtlasTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .overlay(
                    Capsule().strokeBorder(
                        danger ? AtlasTheme.alert.opacity(0.35) : AtlasTheme.separator.opacity(0.7),
                        lineWidth: 1
                    )
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(danger ? "ação destrutiva" : "ação secundária, \(title.lowercased())"))
        .accessibilityAddTraits(.isButton)
    }
}

// Cycle 046 fused AutonomosChrome+Buttons.swift

struct AutonomosPrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.bg)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .frame(minHeight: 48) // HIG 44+; match primary map CTA breath
            .background(
                Capsule().fill(
                    AtlasTheme.accent.opacity(
                        configuration.isPressed && !reduceMotion ? 0.72 : 1
                    )
                )
            )
            .contentShape(Capsule())
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
            .animation(
                reduceMotion
                    ? nil
                    : (configuration.isPressed
                        ? .easeOut(duration: AtlasMotion.instinct)
                        : .spring(response: 0.25, dampingFraction: 0.82)),
                value: configuration.isPressed
            )
    }
}
