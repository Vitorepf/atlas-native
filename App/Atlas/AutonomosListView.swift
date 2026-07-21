import SwiftUI

/// Lista de Autônomos do operador — índice soberano. Vazio até criar. Zero áreas de sistema.
struct AutonomosListView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let units: [AutonomosUnit]
    let onOpen: (AutonomosUnit) -> Void
    let onCreate: () -> Void

    var body: some View {
        Group {
            if units.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .accessibilityIdentifier(A11yID.autonomosList)
    }

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(units) { unit in
                    unitRow(unit)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 12)
            .padding(.bottom, 140)
        }
        .scrollIndicators(.hidden)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer(minLength: 36)
            Text("✦")
                .font(AtlasFont.serif(28))
                .foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .accessibilityHidden(true)
            AutonomosMapChrome.heroTitle("Nenhum ainda", size: 32)
            Text("Crie um Autônomo com escopo fechado. Ele evolui só nisso — 24/7.")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            // Medium: primary entry into create flow on empty catalog.
            AutonomosMapChrome.primaryCTA("Novo Autônomo", haptic: .medium, action: onCreate)
                .accessibilityHint("abre o formulário para criar um Autônomo")
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        // Contain: hero speaks as header; Novo CTA remains a separate target.
        .accessibilityElement(children: .contain)
    }

    private func unitRow(_ unit: AutonomosUnit) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onOpen(unit)
        } label: {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(unit.name)
                        .font(AtlasFont.serif(22, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(unit.charter)
                        .font(AtlasFont.serifItalic(14))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(unit.ageLabel)
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                trailing(unit)
            }
            .padding(.vertical, 18)
            .frame(minHeight: 56, alignment: .top)
            .contentShape(Rectangle())
            .opacity(unit.paused ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            AutonomosMapChrome.hairline
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spoken(unit))
        .accessibilityHint("abre o hub deste Autônomo")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.autonomosUnit(unit.id))
    }

    @ViewBuilder
    private func trailing(_ unit: AutonomosUnit) -> some View {
        if unit.paused {
            Text("pausado")
                .font(AtlasFont.mono(10))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .textCase(.uppercase)
                .padding(.top, 6)
        } else {
            Circle()
                .fill(AtlasTheme.accent.opacity(0.85))
                .frame(width: 5, height: 5)
                .padding(.top, 10)
                .accessibilityLabel("vivo")
        }
    }

    private func spoken(_ unit: AutonomosUnit) -> String {
        var parts = [unit.name, unit.charter]
        parts.append(unit.paused ? "pausado" : "vivo")
        parts.append(unit.ageLabel)
        return parts.joined(separator: ", ")
    }
}
