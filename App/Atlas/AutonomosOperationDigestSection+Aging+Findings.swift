import SwiftUI
import AtlasCore

// Findings by risk — peel de AutonomosOperationDigestSection+Aging.

extension AutonomosOperationDigestSection {
    @ViewBuilder
    var digestFindingsByRisk: some View {
        if !findingsByRisk.isEmpty {
            HStack(spacing: 6) {
                ForEach(findingsByRisk.sorted(by: { $0.value > $1.value }), id: \.key) { risk, n in
                    AutonomosChrome.tag("\(n) \(Self.riskLabel(risk, count: n))")
                }
            }
            .accessibilityHidden(true)
        }
    }

    /// "medium: 100" → "100 médias"; slug desconhecido fica como veio.
    static func riskLabel(_ risk: String, count: Int) -> String {
        let plural = count != 1
        switch risk {
        case "low": return plural ? "baixas" : "baixa"
        case "medium": return plural ? "médias" : "média"
        case "high": return plural ? "altas" : "alta"
        case "critical": return plural ? "críticas" : "crítica"
        default: return risk
        }
    }
}
