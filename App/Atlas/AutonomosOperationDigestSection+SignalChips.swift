import SwiftUI
import AtlasCore

// Signal chips — peel de AutonomosOperationDigestSection+SignalMeta.

extension AutonomosOperationDigestSection {
    var digestSignalChips: some View {
        HStack(spacing: 8) {
            if deliveredTotal > 0 { AutonomosChrome.digestChip("\(deliveredTotal)", "entregues · merge") }
            if pendingCount > 0 { AutonomosChrome.digestChip("\(pendingCount)", "tarefas na fila") }
            if inboxCount > 0 { AutonomosChrome.digestChip("\(inboxCount)", "decisões aguardam") }
        }
        .animation(reduceMotion ? nil : .default, value: deliveredTotal)
        .animation(reduceMotion ? nil : .default, value: pendingCount)
        .animation(reduceMotion ? nil : .default, value: inboxCount)
    }
}
