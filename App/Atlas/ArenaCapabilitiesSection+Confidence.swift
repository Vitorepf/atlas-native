import SwiftUI
import AtlasCore

// Confiança + delta por capacidade — peel de ArenaCapabilitiesSection+Rows.
//
// Lei do operador: número não confiável = não medido, nunca falso. A barra dupla
// mostra o ponto; ESTA linha diz se dá pra confiar: quantos casos (N), se o Atlas
// melhora/piora de verdade (IC de Newcombe não cruza zero) ou se ainda é ruído.
// Sem os dois braços não há comparação — dito, nunca em silêncio.
extension ArenaCapabilityRow {
    @ViewBuilder
    var confidenceCaption: some View {
        HStack(spacing: 5) {
            Image(systemName: confidenceGlyph)
                .font(.system(size: 9, weight: .semibold))
            Text(confidenceText)
                .font(AtlasFont.mono(10))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(confidenceColor)
        .accessibilityHidden(true)
    }

    private var deltaN: Int {
        min(capability.baselineCases ?? 0, capability.withAtlasCases ?? 0)
    }

    private var confidenceText: String {
        switch capability.confidenceLevel {
        case .unmeasured:
            // Descarte alto vem ANTES das outras razões: "rodou e nada chegou ao
            // corretor" não é "nunca rodou". Sem esta linha o app mostraria o silêncio
            // de um braço cuja nota só subiu porque toda falha dele foi descartada.
            if let rate = capability.maxExclusionRate, rate >= 0.5 {
                return "\(Int((rate * 100).rounded()))% descartado no setup · não medível"
            }
            return capability.withAtlas == nil ? "Atlas ainda não rodou aqui" : "sem par para comparar"
        case .low:
            let n = capability.withAtlasCases ?? capability.baselineCases ?? 0
            return "poucos casos (N \(n)) · baixa confiança"
        case .measured:
            let delta = ArenaFormat.signed(capability.delta?.value)
            if capability.delta?.significant == true {
                let verb = (capability.delta?.value ?? 0) >= 0 ? "Atlas melhora" : "Atlas piora"
                return "\(verb) \(delta) · confirmado (N \(deltaN))"
            }
            return "Atlas \(delta) · dentro do ruído (N \(deltaN))"
        }
    }

    private var confidenceColor: Color {
        switch capability.confidenceLevel {
        case .unmeasured, .low:
            return AtlasTheme.textTertiary
        case .measured:
            guard capability.delta?.significant == true else { return AtlasTheme.textSecondary }
            return (capability.delta?.value ?? 0) >= 0 ? AtlasTheme.accent : AtlasTheme.alert
        }
    }

    private var confidenceGlyph: String {
        switch capability.confidenceLevel {
        case .unmeasured: return "circle.dotted"
        case .low: return "exclamationmark.triangle"
        case .measured:
            guard capability.delta?.significant == true else { return "equal.circle" }
            return (capability.delta?.value ?? 0) >= 0 ? "checkmark.seal" : "arrow.down.right.circle"
        }
    }
}
