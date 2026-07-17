import SwiftUI
import AtlasCore

// Week section — peel de AtlasCodeGraphChrome+Status.

extension AtlasCodeView {
    /// A semana + o recibo da noite: fatos consumados, nunca pedidos.
    var weekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let week = model.week {
                HStack(alignment: .firstTextBaseline) {
                    Text("A semana")
                        .font(AtlasFont.serif(18, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    Text(week.window)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                if AtlasCodeWeekUI.isQuiet(week) {
                    Text("semana quieta · sem commits nem curas")
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textSecondary)
                } else {
                    HStack(spacing: 18) {
                        if week.commits > 0 { weekMetric("commits", value: week.commits) }
                        if week.heals > 0 { weekMetric("curas", value: week.heals) }
                        if week.prevented > 0 { weekMetric("prevenidas", value: week.prevented) }
                    }
                }
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.28), value: week.commits + week.heals + week.prevented)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(AtlasCodeWeekUI.spokenLabel(week))
                .accessibilityIdentifier(A11yID.codeWeek)
            }

            if model.hasHealReceipt {
                Button { showsHealReceipt = true } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal")
                            .font(.system(size: 12))
                            .foregroundStyle(AtlasCodePalette.healed)
                        Text("curado sozinho · ver recibo")
                            .font(AtlasFont.serifItalic(13))
                            .foregroundStyle(AtlasTheme.textSecondary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .padding(.vertical, 11)
                    .padding(.horizontal, 13)
                    .background(AtlasCodePalette.healed.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(AtlasCodePalette.healed.opacity(0.3), lineWidth: 1)
                    )
                }
                .accessibilityIdentifier(A11yID.codeHealReceipt)
                .accessibilityLabel("curado sozinho, ver recibo de cura")
                .accessibilityHint("abre os passos registrados pelo servidor")
            }
        }
    }
}
