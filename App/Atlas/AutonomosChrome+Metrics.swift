import SwiftUI
import AtlasCore

// Métricas e estados vazios — peel de AutonomosChrome.

struct FleetMetric: View {
    let value: String; let label: String
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value).font(AtlasFont.mono(18)).foregroundStyle(AtlasTheme.textPrimary)
                .contentTransition(.numericText())
            Text(label).font(.caption2).foregroundStyle(AtlasTheme.textTertiary).lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(11)
        .atlasCard(cornerRadius: 12)
    }
}

struct DetailMetric: View {
    let label: String; let value: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(AtlasFont.mono(15)).foregroundStyle(AtlasTheme.textPrimary)
                .modifier(NumericTextTransition(enabled: !reduceMotion))
            Text(label).font(.caption2).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Card vazio Autônomos — caption + copy editorial (frota, histórico, digest).
struct AutonomosCardEmptyState: View {
    let caption: String
    let copy: String
    let accessibilityIdentifier: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AutonomosChrome.sectionCaption(caption)
            Text(copy)
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .atlasCard(cornerRadius: 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(copy)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

struct AutonomosFleetEmptyState: View {
    enum Kind { case noAgents, noHistory }

    let kind: Kind

    var body: some View {
        AutonomosCardEmptyState(
            caption: kind == .noAgents ? "frota" : "histórico",
            copy: copy,
            accessibilityIdentifier: kind == .noAgents ? A11yID.autonomosFleetEmpty : A11yID.autonomosFleetHistoryEmpty
        )
    }

    private var copy: String {
        switch kind {
        case .noAgents:
            return "Nenhum agente publicado neste recorte — o servidor ainda não registrou a frota."
        case .noHistory:
            return "Histórico vazio — nenhum evento de governança registrado ainda."
        }
    }
}
