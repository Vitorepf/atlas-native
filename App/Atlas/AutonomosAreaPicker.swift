import SwiftUI
import AtlasCore

/// Lista de instâncias (áreas) — seleção dispara `selectArea` no model.
struct AutonomosAreaPicker: View {
    let areas: [AtlasAutonomosArea]
    let selectedAreaID: String?
    let onSelect: (String) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AutonomosChrome.sectionCaption("INSTÂNCIAS")
            ForEach(Array(areas.enumerated()), id: \.element.id) { index, area in
                areaRow(area: area, index: index)
            }
        }
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: selectedAreaID)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AutonomosAreaPickerA11y.spokenSection(count: areas.count))
        .accessibilityIdentifier(A11yID.autonomosAreaPicker)
    }

    @ViewBuilder
    private func areaRow(area: AtlasAutonomosArea, index: Int) -> some View {
        let isSelected = area.id == selectedAreaID
        Button {
            if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
            onSelect(area.id)
        } label: {
            HStack(spacing: 10) {
                Circle().fill(areaStateColor(area)).frame(width: 8, height: 8)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(area.areaName).font(.system(.footnote, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text(area.objective).font(.caption).foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1)
                }
                Spacer()
                Text(areaStateLabel(area)).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(isSelected ? AtlasTheme.surfaceHi : AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            AutonomosAreaPickerA11y.spokenRow(area, index: index, total: areas.count, isSelected: isSelected)
        )
        .accessibilityHint(AutonomosAreaPickerA11y.spokenRowHint())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier(A11yID.autonomosAreaPickerRow(index))
    }

    private func areaStateLabel(_ area: AtlasAutonomosArea) -> String {
        switch area.loopStatus.phase {
        case .terminated: return "encerrada"
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "sem lease"
        }
    }

    private func areaStateColor(_ area: AtlasAutonomosArea) -> Color {
        switch area.loopStatus.phase {
        case .terminated: return AtlasTheme.domOperacional
        case .paused: return AtlasTheme.accent
        case .running: return AtlasTheme.domAutonomos
        case .idle: return AtlasTheme.textTertiary
        }
    }
}
