import SwiftUI
import AtlasCore

// Spoken chip row — peel de PlanCard+A11yStep.

extension PlanCard {
    func spokenChipRow(label: String, items: [String]) -> String {
        "\(label), \(items.count) itens, \(items.joined(separator: ", "))"
    }
}
