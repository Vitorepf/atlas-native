import SwiftUI
import ActivityKit
import AtlasCore

// Timer frame chrome — peel de AtlasTurnWidget+Timer.

extension AtlasTurnWidgetTimer {
    var timerFrameChrome: some View {
        timerText
            .font(.system(size: fontSize, design: .monospaced))
            .foregroundStyle(Ink.ink2)
            .frame(width: frameWidth)
            .padding(.trailing, trailingPadding)
    }
}
