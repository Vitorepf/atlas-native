import SwiftUI
import AtlasCore

// Timing word label — peel de LiveNowRow+TimingLine+Stack.

extension LiveNowRow {
    var timingLineWordLabel: some View {
        Text(timingWord)
            .font(AtlasFont.mono(10))
            .tracking(0.3)
            .foregroundStyle(timingColor)
    }
}
