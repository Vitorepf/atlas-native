import SwiftUI
import AtlasCore

// Week section — peel de AtlasCodeGraphChrome+Status.
// Heal → AtlasCodeGraphChrome+WeekHeal.swift

extension AtlasCodeView {
    /// A semana + o recibo da noite: fatos consumados, nunca pedidos.
    var weekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let week = model.week {
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
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(AtlasCodeWeekUI.spokenLabel(week))
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier(A11yID.codeWeek)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 0.28),
                    value: AtlasCodeWeekUI.weekPhaseID(week)
                )
            }

            weekHealReceiptButton
        }
    }
}
