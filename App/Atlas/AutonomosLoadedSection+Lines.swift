import SwiftUI
import AtlasCore

// Info line — peel de AutonomosLoadedSection.
// Receipt/error → AutonomosLoadedSection+ReceiptCards.swift
// Optional a11y → AutonomosLoadedSection+OptionalA11y.swift
// Init → AutonomosLoadedSection+Lines+Init.swift
// Body → AutonomosLoadedSection+Lines+Body.swift

struct AutonomosInfoLine: View {
    let text: String
    let spokenLabel: String
    let identifier: String?

    var body: some View {
        infoLineBody
    }
}
