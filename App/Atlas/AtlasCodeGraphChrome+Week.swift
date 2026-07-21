import SwiftUI
import AtlasCore

// Semana + recibo de cura no grafo (WAVE-001 W3 fuse).

extension AtlasCodeView {
    /// A semana + o recibo da noite: fatos consumados, nunca pedidos.
    var weekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let week = model.week {
                weekBody(week)
            }
            weekHealReceiptButton
        }
    }

    @ViewBuilder
    func weekBody(_ week: AtlasCodeWeek) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("A semana")
                    .font(AtlasFont.serif(18, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                Spacer()
                Text(week.window)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            weekMetricsOrQuiet(week)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AtlasCodeWeekUI.spokenLabel(week))
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier(A11yID.codeWeek)
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.28),
            value: AtlasCodeWeekUI.weekPhaseID(week)
        )
    }

    @ViewBuilder
    func weekMetricsOrQuiet(_ week: AtlasCodeWeek) -> some View {
        if AtlasCodeWeekUI.isQuiet(week) {
            Text("semana quieta · sem commits nem curas")
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        } else {
            HStack(spacing: 18) {
                if week.commits > 0 { weekMetric("commits", value: week.commits) }
                if week.heals > 0 { weekMetric("curas", value: week.heals) }
                if week.prevented > 0 { weekMetric("prevenidas", value: week.prevented) }
            }
            .accessibilityHidden(true)
        }
    }

    func weekMetric(_ label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(String(value))
                .font(AtlasFont.serif(21, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .monospacedDigit()
            Text(label)
                .atlasSans(10)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }

    @ViewBuilder
    var weekHealReceiptButton: some View {
        if model.hasHealReceipt {
            Button { showsHealReceipt = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal")
                        .atlasSans(12)
                        .foregroundStyle(AtlasCodePalette.healed)
                        .accessibilityHidden(true)
                    Text("curado sozinho · ver recibo")
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .accessibilityHidden(true)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .atlasSans(10, .semibold)
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
                .padding(.vertical, 11)
                .padding(.horizontal, 13)
                .background(AtlasCodePalette.healed.opacity(0.07), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
                .overlay(
                    RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                        .strokeBorder(AtlasCodePalette.healed.opacity(0.3), lineWidth: 1)
                )
            }
            .accessibilityIdentifier(A11yID.codeHealReceipt)
            .accessibilityLabel("curado sozinho, ver recibo de cura")
            .accessibilityHint("abre os passos registrados pelo servidor")
        }
    }
}
