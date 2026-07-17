import SwiftUI
import AtlasCore

// Rhythm line — peel de AutonomosAwaitingSection+Blocks.

struct AutonomosRhythmLearningLine: View {
    let sampleDays: Int?

    var body: some View {
        if let sampleDays, sampleDays < 4 {
            Text("aprendendo seu ritmo · dia \(max(1, sampleDays)) de 4")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("aprendendo seu ritmo, dia \(max(1, sampleDays)) de 4")
        }
    }
}
