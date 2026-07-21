import SwiftUI
import AtlasCore

// Axis header spoken — peel de ChangeReviewFindingsSection+Axis.

extension ChangeReviewFindingsSection {
    func axisHeaderLabel(axis: String, count: Int) -> String {
        let name = axis == "GERAIS" ? "gerais" : axis.lowercased()
        let noun = count == 1 ? "achado" : "achados"
        return "eixo \(name), \(count) \(noun)"
    }
}
