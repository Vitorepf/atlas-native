import SwiftUI

// MARK: - Kicker

struct ArenaPremiumKicker: View {
    let text: String
    var tone: ArenaPremiumTone = .neutral
    /// Live: ✦ que respira (nunca bola). Demais kickers sem marca.
    var showsLiveMark = false

    var body: some View {
        HStack(spacing: 8) {
            if showsLiveMark {
                Text("✦")
                    .font(AtlasFont.serif(11))
                    .foregroundStyle(tone.color)
                    .modifier(ArenaLiveBreath())
                    .accessibilityHidden(true)
            }
            Text(text.uppercased())
                .font(AtlasFont.mono(10, .medium))
                .tracking(1.6)
                .foregroundStyle(tone.color)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Compat: kickers antigos com `showsDot:` viram marca ✦ quando true.
extension ArenaPremiumKicker {
    init(text: String, tone: ArenaPremiumTone = .neutral, showsDot: Bool) {
        self.init(text: text, tone: tone, showsLiveMark: showsDot)
    }
}

private struct ArenaLiveBreath: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var on = false

    func body(content: Content) -> some View {
        content
            .opacity(reduceMotion ? 1 : (on ? 1 : 0.55))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(AtlasMotion.breath(2.4)) { on = true }
            }
    }
}

// MARK: - Hairline · action

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
    var symbol: String? = nil
    var tone: ArenaPremiumTone = .neutral
    var quiet = false
    var disabled = false
    let action: () -> Void

    /// Compat com call sites que passam SF Symbol.
    init(
        title: String,
        symbol: String,
        tone: ArenaPremiumTone = .neutral,
        quiet: Bool = false,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.symbol = symbol
        self.tone = tone
        self.quiet = quiet
        self.disabled = disabled
        self.action = action
    }

    init(
        title: String,
        tone: ArenaPremiumTone = .neutral,
        quiet: Bool = false,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.symbol = nil
        self.tone = tone
        self.quiet = quiet
        self.disabled = disabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .atlasSans(14, quiet ? .regular : .medium)
                .frame(maxWidth: .infinity, minHeight: 46)
                .padding(.horizontal, 20)
                .foregroundStyle(disabled ? AtlasTheme.textTertiary : (quiet ? AtlasTheme.textSecondary : AtlasTheme.textPrimary))
                .background(
                    Capsule().fill(
                        quiet || disabled
                            ? Color.clear
                            : Color.white.opacity(0.055)
                    )
                )
                .overlay(
                    Capsule().stroke(
                        quiet
                            ? AtlasTheme.separator.opacity(disabled ? 0.35 : 0.7)
                            : Color.white.opacity(disabled ? 0.04 : 0.08),
                        lineWidth: 1
                    )
                )
                .contentShape(Capsule())
        }
        .buttonStyle(PressableScale())
        .disabled(disabled)
        .accessibilityLabel(title)
    }
}

// MARK: - Disclosure · ring · empty

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
                // Linha de lista fala sans (canon §C — serif é masthead/título);
                // mesma lei aplicada no Código e nos Artifacts hoje.
                Text(title)
                    .atlasSans(16, .medium)
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
                    .stroke(Color.white.opacity(0.06), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                if let progress {
                    Circle()
                        .trim(from: 0.08, to: 0.08 + 0.84 * min(max(progress, 0), 1))
                        .stroke(AtlasTheme.accent, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                }
            }
            .rotationEffect(.degrees(90))
            if let percentage {
                HStack(alignment: .lastTextBaseline, spacing: 1) {
                    Text("\(percentage)")
                        .font(AtlasFont.serif(42))
                    Text("%")
                        .font(AtlasFont.mono(13))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .baselineOffset(4)
                }
                .foregroundStyle(AtlasTheme.textPrimary)
            } else {
                Text("✦")
                    .font(AtlasFont.serif(24))
                    .foregroundStyle(AtlasTheme.accent)
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
