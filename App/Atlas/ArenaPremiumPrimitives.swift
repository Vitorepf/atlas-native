import SwiftUI

struct ArenaPremiumKicker: View {
    let text: String
    var tone: ArenaPremiumTone = .neutral
    var showsDot = false

    var body: some View {
        HStack(spacing: 10) {
            if showsDot {
                Circle().fill(tone.color).frame(width: 8, height: 8)
            }
            Text(text.uppercased())
                .font(AtlasFont.mono(11, .medium))
                .tracking(1.8)
                .foregroundStyle(tone.color)
        }
        .accessibilityElement(children: .combine)
    }
}

struct ArenaPremiumHairline: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [AtlasTheme.separator.opacity(0.2), AtlasTheme.separator, AtlasTheme.separator.opacity(0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

struct ArenaPremiumAction: View {
    let title: String
    let symbol: String
    var tone: ArenaPremiumTone = .active
    var disabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                ArenaPremiumIcon(
                    symbol: symbol,
                    tone: disabled ? .muted : tone
                )
                Text(title)
            }
                .font(.system(.callout, weight: .semibold))
                .frame(minHeight: 48)
                .padding(.horizontal, 20)
                .foregroundStyle(disabled ? AtlasTheme.textTertiary : tone.color)
                .background(Capsule().fill(tone.color.opacity(disabled ? 0.03 : 0.08)))
                .overlay(Capsule().stroke(tone.color.opacity(disabled ? 0.16 : 0.45), lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(PressableScale())
        .disabled(disabled)
    }
}

struct ArenaPremiumDisclosureRow: View {
    let title: String
    let detail: String
    let symbol: String
    var tone: ArenaPremiumTone = .neutral
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ArenaPremiumIcon(symbol: symbol, tone: tone)
                Text(title)
                    .font(AtlasFont.serif(18))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer(minLength: 12)
                Text(detail)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(tone.color)
                    .lineLimit(1)
                ArenaPremiumChevron()
            }
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ArenaPremiumProgressRing: View {
    let progress: Double?
    let percentage: Int?

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .trim(from: 0.08, to: 0.92)
                    .stroke(AtlasTheme.surfaceHi, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                if let progress {
                    Circle()
                        .trim(from: 0.08, to: 0.08 + 0.84 * min(max(progress, 0), 1))
                        .stroke(AtlasTheme.accent, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                }
            }
            .rotationEffect(.degrees(90))
            if let percentage {
                HStack(alignment: .lastTextBaseline, spacing: 1) {
                    Text("\(percentage)")
                        .font(AtlasFont.serif(50))
                    Text("%")
                        .font(AtlasFont.serif(25))
                }
                .foregroundStyle(AtlasTheme.textPrimary)
            } else {
                ArenaPremiumIcon(symbol: "ellipsis", role: .standard)
            }
        }
        .frame(width: 142, height: 142)
        .accessibilityHidden(true)
    }
}

struct ArenaPremiumEmptyGlyph: View {
    let symbol: String
    var tone: ArenaPremiumTone = .neutral

    var body: some View {
        ArenaPremiumIcon(symbol: symbol, tone: tone, role: .hero)
            .background(Circle().fill(AtlasTheme.surface.opacity(0.72)))
            .overlay(Circle().stroke(AtlasTheme.separator, lineWidth: 1))
    }
}
