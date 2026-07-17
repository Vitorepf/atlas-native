import SwiftUI
import AtlasCore

// Chips + aging + findings — peel de AutonomosOperationDigestSection+Body.

extension AutonomosOperationDigestSection {
    @ViewBuilder
    var digestSignalMeta: some View {
        HStack(spacing: 8) {
            if deliveredTotal > 0 { AutonomosChrome.digestChip("\(deliveredTotal)", "entregues · merge") }
            if pendingCount > 0 { AutonomosChrome.digestChip("\(pendingCount)", "tarefas na fila") }
            if inboxCount > 0 { AutonomosChrome.digestChip("\(inboxCount)", "decisões aguardam") }
        }
        .animation(reduceMotion ? nil : .default, value: deliveredTotal)
        .animation(reduceMotion ? nil : .default, value: pendingCount)
        .animation(reduceMotion ? nil : .default, value: inboxCount)
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
