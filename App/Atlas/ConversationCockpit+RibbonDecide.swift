import SwiftUI
import AtlasCore

// Ribbon decide line — peel de ConversationCockpit+Ribbon.

extension ExecutionRibbon {
    @ViewBuilder
    var decideStrategyLine: some View {
        if let strat = bubble.decideStrategy {
            Text("atlas decide · \(strat)" + (bubble.decideStage.map { " → \($0)" } ?? ""))
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).padding(.leading, 24)
        }
    }
}
