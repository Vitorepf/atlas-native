import SwiftUI
import AtlasCore

/// Lista de instâncias (áreas) — seleção dispara `selectArea` no model.
/// Row → AutonomosAreaPicker+Row.swift
struct AutonomosAreaPicker: View {
    let areas: [AtlasAutonomosArea]
    let selectedAreaID: String?
    let onSelect: (String) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

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
}
