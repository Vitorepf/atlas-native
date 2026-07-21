import SwiftUI
import AtlasCore

/// Thin multi-area bind chooser (WAVE-065) — registered only, no monólito picker.
struct AutonomosAreaBindChooser: View {
    let areas: [AtlasAutonomosArea]
    let onSelect: (String) -> Void
    let onCancel: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var ranked: [AtlasAutonomosArea] {
        AutonomosAreaBindJudgment.rankForChooser(areas)
    }

    var body: some View {
        NavigationStack {
            Group {
                if ranked.isEmpty {
                    emptySilence
                } else {
                    areaList
                }
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Área do loop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    AtlasCloseToolbarButton(
                        spokenLabel: "fechar escolha de área",
                        spokenHint: "volta sem ligar área",
                        reduceMotion: reduceMotion
                    ) { onCancel() }
                }
            }
            .accessibilityIdentifier(A11yID.autonomosAreasSheet)
            .accessibilityLabel(
                AutonomosAreaBindJudgment.spokenChooser(count: ranked.count)
            )
            .accessibilityValue(AutonomosAreaBindFace.needsBind(ranked.count).productWord)
            .accessibilityHint(AutonomosAreaBindJudgment.chooserHint)
        }
    }

    private var emptySilence: some View {
        VStack(spacing: 12) {
            Text("Nenhuma área registrada")
                .font(AtlasFont.serif(18, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text("O motor não publicou áreas controláveis neste recorte.")
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(36)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AutonomosAreaBindFace.none.spokenFace)
    }

    private var areaList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(AutonomosAreaBindJudgment.chooserHint)
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    .accessibilityHidden(true)

                ForEach(Array(ranked.enumerated()), id: \.element.id) { index, area in
                    if index > 0 {
                        Rectangle()
                            .fill(AtlasTheme.separator.opacity(0.55))
                            .frame(height: 1)
                            .padding(.horizontal, AtlasTheme.Space.screen)
                    }
                    areaRow(area, index: index)
                }
            }
            .padding(.bottom, 24)
        }
    }

    private func areaRow(_ area: AtlasAutonomosArea, index: Int) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onSelect(area.id)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(area.areaName.isEmpty ? area.id : area.areaName)
                    .font(AtlasFont.serif(17, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !area.focus.isEmpty {
                    Text(area.focus)
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AutonomosAreaBindJudgment.spokenChooserRow(area))
        .accessibilityHint("liga o loop a esta área")
        .accessibilityIdentifier(A11yID.autonomosAreaBindRow(area.id))
    }
}

// MARK: - Hub CTA strip

struct AutonomosAreaBindCTA: View {
    let registeredCount: Int
    let onChoose: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onChoose()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "square.grid.2x2")
                    .atlasSans(14, .semibold)
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(AutonomosAreaBindJudgment.ctaTitle)
                        .font(AtlasFont.mono(12, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text("\(registeredCount) áreas registradas — sem área o hub fica quieto")
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .atlasSans(12, .semibold)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(14)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control, fillOpacity: 0.55)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AutonomosAreaBindJudgment.ctaSpoken)
        .accessibilityHint(AutonomosAreaBindJudgment.chooserHint)
        .accessibilityValue(AutonomosAreaBindFace.needsBind(registeredCount).productWord)
        .accessibilityIdentifier(A11yID.autonomosAreaBindCTA)
    }
}
