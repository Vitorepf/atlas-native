import SwiftUI
import AtlasCore

// Quiet body — peel de AutonomosFleetTaskHealth+Bodies.
// Copy → AutonomosFleetTaskHealth+QuietCopy.swift
// A11y → AutonomosFleetTaskHealth+QuietA11y.swift

extension AutonomosTaskHealthSection {
    var quietBody: some View {
        quietA11y(
            VStack(alignment: .leading, spacing: 6) {
                AutonomosChrome.sectionCaption("fila", role: .header)
                quietCopy
            }
        )
    }
}
