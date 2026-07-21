import SwiftUI
import AtlasCore

// IDLE-COMPRESS Arena peels

// --- ArenaPremiumGlyphRow.swift ---
struct ArenaPremiumGlyphRow: View {
    let glyph: String
    let title: String
    let detail: String
    var tone: ArenaPremiumTone = .neutral
    var glyphTone: ArenaPremiumTone? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(glyph)
                    .font(AtlasFont.serif(14))
                    .foregroundStyle((glyphTone ?? tone).color)
                    .frame(width: 22, alignment: .center)
                    .accessibilityHidden(true)
                Text(title)
                    .atlasSans(16, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer(minLength: 12)
                Text(detail)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(tone.color)
                    .lineLimit(1)
                Text("›")
                    .font(AtlasFont.mono(13))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// --- ArenaPremiumOperationalRows.swift ---
struct ArenaPremiumOperationalRows: View {
    @Bindable var model: ArenaModel
    let onNavigate: (ArenaPremiumDestination) -> Void

    private var alertCount: Int { model.arenaAlertSuiteCount }

    var body: some View {
        // Sem exceção: some a seção. Fila/Cobertura/Próxima/Plano moram
        // DENTRO de Execução — duplicar aqui era a confusão.
        if alertCount > 0 {
            VStack(spacing: 0) {
                ArenaPremiumHairline()
                ArenaPremiumGlyphRow(
                    glyph: "※",
                    title: "Alertas",
                    detail: alertCount == 1 ? "1 exceção" : "\(alertCount) exceções",
                    tone: .negative,
                    glyphTone: .negative
                ) { onNavigate(.alerts) }
                .accessibilityIdentifier(A11yID.arenaPremiumAlertsAction)
            }
        }
    }
}

