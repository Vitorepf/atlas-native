import SwiftUI
import AtlasCore

// Aging + findings do digest — peel de AutonomosOperationDigestSection+SignalMeta.

extension AutonomosOperationDigestSection {
    @ViewBuilder
    var digestAgingFindings: some View {
        if let oldest = oldestBacklogCreatedAt {
            Text("item mais antigo · \(AutonomosChrome.relativeAge(from: oldest))")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.domOperacional)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
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
