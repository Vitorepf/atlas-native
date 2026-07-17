import SwiftUI
import AtlasCore

// Findings by risk — peel de AutonomosOperationDigestSection+Aging.

extension AutonomosOperationDigestSection {
    @ViewBuilder
    var digestFindingsByRisk: some View {
        if !findingsByRisk.isEmpty {
            HStack(spacing: 6) {
                ForEach(findingsByRisk.sorted(by: { $0.value > $1.value }), id: \.key) { risk, n in
                    AutonomosChrome.tag("\(risk): \(n)")
                }
            }
            .accessibilityHidden(true)
        }
    }
}
