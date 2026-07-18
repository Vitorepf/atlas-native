import SwiftUI
import AtlasCore

/// Capacidades — o hero da Arena (goal do operador 2026-07-17): desempenho
/// por habilidade, sem e com Atlas. Sem medição = ausência DITA, nunca
/// silêncio — o operador precisa saber que a dimensão existe e está vazia.
/// Header → ArenaCapabilitiesSection+Header.swift
/// Body → ArenaCapabilitiesSection+MeasuredBody.swift
struct ArenaCapabilitiesSection: View {
    let capabilities: AtlasArenaCapabilities?
    let reduceMotion: Bool
    /// Motores com perfil disponível (2+ → seletor no hero); default vazio
    /// preserva o uso dentro do ArenaEngineSheet (motor fixo).
    var engineOptions: [String] = []
    var onSelectEngine: ((String) -> Void)?

    var measuredCapabilities: [AtlasArenaCapability] {
        capabilities?.capabilities ?? []
    }

    var body: some View {
        if !measuredCapabilities.isEmpty, let capabilities {
            capabilitiesMeasuredBody(capabilities)
        } else {
            capabilitiesUnmeasuredCard
        }
    }

    /// Chips de motor — troca o perfil sem sair do hero (goal 3).
    @ViewBuilder
    var engineChips: some View {
        if engineOptions.count > 1, let onSelectEngine {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(engineOptions, id: \.self) { engine in
                        engineChip(engine, isSelected: engine == capabilities?.engine, action: onSelectEngine)
                    }
                }
            }
        }
    }

    func engineChip(_ engine: String, isSelected: Bool, action: @escaping (String) -> Void) -> some View {
        Button { action(engine) } label: {
            Text(ArenaDisplay.engine(engine))
                .font(.system(.caption, weight: .medium))
                .foregroundStyle(isSelected ? AtlasTheme.accent : AtlasTheme.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(isSelected ? AtlasTheme.goldVeil : AtlasTheme.surfaceHi))
                .overlay(Capsule().stroke(isSelected ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("capacidades de \(ArenaDisplay.engine(engine))")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("arena-capability-engine-\(engine)")
    }

    /// Ausência dita, mas em sussurro: um card vazio não pode pesar mais que
    /// conteúdo real. A dimensão existe e está vazia — uma linha basta.
    var capabilitiesUnmeasuredCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("CAPACIDADES")
                .font(.system(.caption, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
            engineChips
            Text("nenhuma medida ainda — rode uma medição")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("capacidades, nenhuma medida ainda")
        .accessibilityIdentifier(A11yID.arenaCapabilitiesSection)
    }
}
