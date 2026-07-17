import Foundation
import AtlasCore

/// Spoken labels do seletor de instâncias — peel de AutonomosAreaPicker (CICLO C).
/// Fase canônica do Core; `registered` só quando o payload nega registro.
/// Phase → AutonomosAreaPicker+A11yPhase.swift
/// Row → AutonomosAreaPicker+A11yRow.swift

enum AutonomosAreaPickerA11y {
    static func spokenSection(count: Int) -> String {
        guard count > 0 else { return "instâncias, nenhuma área publicada" }
        return "instâncias, \(count) área\(count == 1 ? "" : "s")"
    }
}
