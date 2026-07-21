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
    }

    static func heroTitle(_ text: String, size: CGFloat = 30) -> some View {
        Text(text)
            .font(AtlasFont.serif(size, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    static func heroSub(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
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
    }

    static func section(_ text: String) -> some View {
        Text(text.uppercased())
            .font(AtlasFont.mono(10))
            .tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
    }

    static func primaryCTA(_ title: String, enabled: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary.opacity(enabled ? 1 : 0.35))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 46)
                .background(AtlasTheme.textPrimary.opacity(enabled ? 0.055 : 0.03), in: Capsule())
                .overlay(Capsule().strokeBorder(Color.white.opacity(enabled ? 0.08 : 0.04), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    static func quietCTA(_ title: String, danger: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(danger ? AtlasTheme.alert : AtlasTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 46)
                .overlay(
                    Capsule().strokeBorder(
                        danger ? AtlasTheme.alert.opacity(0.35) : AtlasTheme.separator.opacity(0.7),
                        lineWidth: 1
                    )
                )
        }
        .buttonStyle(.plain)
    }
}
